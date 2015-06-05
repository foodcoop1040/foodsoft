# -*- coding: utf-8 -*-
# Configures your navigation

SimpleNavigation::Configuration.run do |navigation|

  # allow engines to add to the menu - https://gist.github.com/mjtko/4873ee0c112b6bd646f8
  engines = Rails::Engine.subclasses.map(&:instance).select { |e| e.respond_to?(:navigation) }
  # to include an engine but keep it from modifying the menu:
  #engines.reject! { |e| e.instance_of? FoodsoftMyplugin::Engine }

  # There may be plugins (forum) that use this layout from within an engine. In that case,
  # all url helpers must be prefixed with the engine. In the default Foodsoft navigation,
  # we only link to default routes available in the main app. This is a shorthand.
  # Don't forget to use this, because it will work until an engine uses the default layout.
  m = main_app

  navigation.items do |primary|
    primary.dom_class = 'nav'

    primary.item :dashboard_nav_item, I18n.t('navigation.dashboard'), m.root_path(anchor: '')

    primary.item :foodcoop, I18n.t('navigation.foodcoop'), '#' do |subnav|
      subnav.item :members, I18n.t('navigation.members'), m.foodcoop_users_path
      subnav.item :workgroups, I18n.t('navigation.workgroups'), m.foodcoop_workgroups_path
      subnav.item :ordergroups, I18n.t('navigation.ordergroups'), m.foodcoop_ordergroups_path
      subnav.item :tasks, I18n.t('navigation.tasks'), m.tasks_path
    end

    primary.item :orders, I18n.t('navigation.orders.title'), '#' do |subnav|
      subnav.item :ordering, I18n.t('navigation.orders.ordering'), m.group_orders_path
      subnav.item :ordering_archive, I18n.t('navigation.orders.archive'), m.archive_group_orders_path
      subnav.item :expected_delivery, I18n.t('navigation.orders.expected_delivery'), m.expected_delivery_orders_path
      subnav.item :orders, I18n.t('navigation.orders.manage'), m.orders_path, if: Proc.new { current_user.role_orders? }
    end

    primary.item :articles, I18n.t('navigation.articles.title'), '#',
                 if: Proc.new { current_user.role_article_meta? or current_user.role_suppliers? } do |subnav|
      subnav.item :suppliers, I18n.t('navigation.articles.suppliers'), m.suppliers_path
      subnav.item :stockit, I18n.t('navigation.articles.stock'), m.stock_articles_path
      subnav.item :categories, I18n.t('navigation.articles.categories'), m.article_categories_path
    end

    primary.item :finance, I18n.t('navigation.finances.title'), '#', if: Proc.new { current_user.role_finance? or current_user.role_invoices? } do |subnav|
      subnav.item :finance_home, I18n.t('navigation.finances.home'), m.finance_root_path, if: Proc.new { current_user.role_finance? }
      subnav.item :bank_accounts, I18n.t('navigation.finances.bank_accounts'), m.finance_bank_accounts_path, if: Proc.new { current_user.role_finance? }
      subnav.item :accounts, I18n.t('navigation.finances.accounts'), m.finance_ordergroups_path, if: Proc.new { current_user.role_finance? }
      subnav.item :balancing, I18n.t('navigation.finances.balancing'), m.finance_order_index_path, if: Proc.new { current_user.role_finance? }
      subnav.item :invoices, I18n.t('navigation.finances.invoices'), m.finance_invoices_path
    end

    primary.item :admin, I18n.t('navigation.admin.title'), '#', if: Proc.new { current_user.role_admin? } do |subnav|
      subnav.item :admin_home, I18n.t('navigation.admin.home'), m.admin_root_path
      subnav.item :users, I18n.t('navigation.admin.users'), m.admin_users_path
      subnav.item :ordergroups, I18n.t('navigation.admin.ordergroups'), m.admin_ordergroups_path
      subnav.item :workgroups, I18n.t('navigation.admin.workgroups'), m.admin_workgroups_path
      subnav.item :bank_accounts, I18n.t('navigation.admin.bank_accounts'), m.admin_bank_accounts_path
      subnav.item :config, I18n.t('navigation.admin.config'), m.admin_config_path
    end

    engines.each { |e| e.navigation(primary, self) }
  end

end
