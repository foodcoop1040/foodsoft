class DocumentsController < ApplicationController
  inherit_resources

  before_filter -> { require_plugin_enabled FoodsoftDocuments }

  def index
    if params["sort"]
      sort = case params["sort"]
               when "name" then "name"
               when "created_at" then "created_at"
               when "name_reverse" then "name DESC"
               when "created_at_reverse" then "created_at DESC"
             end
    else
      sort = "name"
    end

    @documents = Document.page(params[:page]).per(@per_page).order(sort)
  end

  def new
    @document = Document.new
  end

  def create
    @document = Document.new
    @document.content = params[:document][:content].read
    if params[:document][:name] == ''
      @document.name = params[:document][:content].original_filename
    else
      @document.name = params[:document][:name]
    end
    @document.user = current_user
    @document.save!
    redirect_to documents_path, notice: I18n.t('documents.create.notice')
  rescue => error
    redirect_to documents_path, alert: t('documents.create.error', error: error.message)
  end

  def destroy
    @document = Document.find(params[:id])
    if @document.user == current_user or current_user.role_admin?
      @document.destroy
      redirect_to documents_path, notice: t('documents.destroy.notice')
    else
      redirect_to documents_path, alert: t('documents.destroy.no_right')
    end
  rescue => error
    redirect_to documents_path, alert: t('documents.destroy.error', error: error.message)
  end

  def show
    @document = Document.find(params[:id])
    send_data(@document.content, :filename => @document.name, :type => MIME::Types.type_for(@document.name).first.content_type)
  end
end
