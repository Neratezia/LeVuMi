# -*- encoding : utf-8 -*-
class AddArchiveToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :archive, :boolean
  end
end
