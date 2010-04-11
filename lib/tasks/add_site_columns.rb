class AddSiteColumns < ActiveRecord::Migration
  
  config = VhostExtension.read_config

  MODELS = config[:models]
  
  # Declare the models so we can use them.
  MODELS.each do |model|
    eval "class #{model} < ActiveRecord::Base; end"
  end
  
  def self.up
    MODELS.each do |model|
      puts "Applying scope to #{model}"
      begin
        add_column model.tableize, :site_id, :integer
        # Update all records to have a site_id of 1 (so nothing errors out)
        model.constantize.update_all "site_id = 1"
        # Special case for Snippets to add a proper index
        if model == 'Snippet'
          add_index :snippets, [:name, :site_id], :unique => true
        end
      rescue
        # Ignore errors here, they're going to happen when the user
        # does a 'remigrate'
      end
    end
    add_index :snippets, [:name, :site_id] rescue nil
  end

  def self.down
    MODELS.each do |model|
      begin
        # Special case for Snippets to remove index
        if model == 'Snippet'
          remove_index :snippets, [:name, :site_id]
        end
        remove_column model.tableize, :site_id
      rescue
        # Ignore errors here, they're going to happen when the user
        # does a 'remigrate'
      end
    end
    remove_index :snippets, :column => [:name, :site_id] rescue nil
  end
end
