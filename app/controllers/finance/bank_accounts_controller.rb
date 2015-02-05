class Finance::BankAccountsController < Finance::BaseController

  def index
    @bank_accounts = BankAccount.order('name')
  end

  def import
    @bank_account = BankAccount.find(params[:id])
    begin
      BankTransaction.transaction do
        invalid_transactions = false
        @transactions = get_from_easybank(@bank_account)
        @transactions.each do |t|
          invalid_transactions = true unless t.save!
        end
      end
      # Successfully done.
      redirect_to finance_bank_account_transactions_url(@bank_account), notice: t('finance.bank_accounts.controller.import.notice', :count => @transactions.size)
      rescue => error
      redirect_to finance_bank_account_transactions_url(@bank_account), alert: t('finance.bank_accounts.controller.import.alert', error: error.message)
    end
  end

private
  def get_from_easybank(bank_account)
    easybank_config = FoodsoftConfig[:easybank]
    raise "easybank configuration missing" if not easybank_config

    dn = easybank_config[:dn]
    pin = easybank_config[:pin]
    account = bank_account.iban[-11,11]

    ret = []
    max_number = bank_account.bank_transactions.maximum(:booking_number)

    agent = Mechanize.new
    agent.get("https://ebanking.easybank.at/InternetBanking/InternetBanking?d=login&svc=EASYBANK&ui=html&lang=de")

    loginForm = agent.page.form_with(:name => "loginForm")
    loginForm.field_with(:name => "dn").value = dn
    loginForm.field_with(:name => "pin").value = pin

    financeOverview = loginForm.submit
    financeOverview.search('#' + account).each do |tr|
      tds = tr.css('td')
      bank_account.balance = tds[9].content.gsub(/ EUR/, '').gsub(/\./, '').gsub(/,/, '.').strip.to_f
    end
    bank_account.save!

    financeOverviewForm = financeOverview.form_with(:name => "financeOverviewForm")
    financeOverviewForm.field_with(:name => "activeaccount").value = account
    financeOverviewForm.field_with(:name => "d").value = "transactions"

    transactions = financeOverviewForm.submit

    check_next_page = true
    while check_next_page do
      transactions.search('#exchange-details tbody').each do |tbody|
        tbody.search('tr').each do |tr|
          tds = tr.css('td')
          tds[3].search('br').each do |n|
            n.replace("\t")
          end
          m = tds[3].content.scan(/^(.*)([A-Z]{2})\/(\d{9})\s?((([A-Z]{6}[A-Z0-9]{2}[A-Z0-9]{3}?) )?([A-Z]{2}\d{2}[A-Z0-9]{1,30}))?(.*)/)[0]
          if not m
            raise "Regex does not match"
          end

          if max_number.to_i >= m[2].to_i
            check_next_page = false
            break
          end

          trans = bank_account.bank_transactions.build()
          trans.booking_date = tds[1].content
          trans.value_date = tds[5].content
          trans.amount = tds[9].content.gsub(/\./, '').gsub(/,/, '.')
          trans.booking_type = m[1]
          trans.booking_number = m[2]
          trans.iban = m[6]
          trans.bic = m[5]

          text = [m[0].strip]
          remaining = m[7].split("\t")
          if remaining[0]
            trans.name = remaining[0].strip
            if remaining[1]
              if trans.name != ""
                text.push(remaining[1].strip)
              else
                trans.name = remaining[1].strip
              end
            end
          else
            trans.name = ''
          end

          case trans.booking_type
          when 'BG'
            if text[0] =~ /\d+/
              trans.reference = text[0].to_i
            end
          when 'VD'
            if text[0] =~ /Gutschrift .+ (\d+)/
              trans.reference = $1.to_i
            end
          end

          beleg = tds[11].css('a')[0]
          if beleg
            url = beleg["onclick"].split("'")[1]
            param = CGI.parse(URI.parse(url).query)
            d = param['d']
            if d.class == Array
              d = d.join('')
            end
            if d == 'image'
              trans.image = agent.get(agent.get(url).search("body>div>img")[0]["src"]).content.read
            else
              tds2 = agent.get(url).search('td.supplementtext')
              trans.receipt = ''
              tds2.each do |td|
                trans.receipt += td.content + "\n"
              end
              m2 = tds2[22].content.scan(/^(\d{12})                             EUR/)[0]
              if m2
                trans.reference = m2[0].to_i
              end
            end
          end

          trans.text = text.join("\n")
          ret.push(trans)
        end
      end

      if not transactions.search("a.next")[0]["onclick"]
        break
      end

      transactionSearchForm = transactions.form_with(:name => "transactionSearchForm")
      pn = transactionSearchForm.field_with(:name => "pagenumber")
      pn.value = (pn.value.to_i + 1).to_s
      transactions = transactionSearchForm.submit
    end

    navigationform = transactions.form_with(:name => "navigationform")
    navigationform.field_with(:name => "d").value = "logoutredirect"
    navigationform.submit

    ret.reverse
  end
end
