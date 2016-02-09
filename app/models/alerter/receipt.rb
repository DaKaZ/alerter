class Alerter::Receipt < ActiveRecord::Base
  self.table_name = :alerter_receipts
  attr_accessible :is_read, :deleted if Alerter.protected_attributes?

  belongs_to :receiver, :polymorphic => :true
  belongs_to :message, :class_name => "Alerter::Message", :foreign_key => "message_id"

  validates_presence_of :receiver

  scope :recipient, lambda { |recipient|
    where(:receiver_id => recipient.id, :receiver_type => recipient.class.base_class.to_s)
  }

  scope :inbox, lambda {
    where(:mailbox_type => "inbox")
  }
  scope :deleted, lambda {
    where(:deleted => true)
  }
  scope :not_deleted, lambda {
    where(:deleted => false)
  }
  scope :is_read, lambda {
    where(:is_read => true)
  }
  scope :is_unread, lambda {
    where(:is_read => false)
  }


  class << self
    #Marks all the receipts from the relation as read
    def mark_as_read(options={})
      update_receipts({:is_read => true}, options)
    end

    #Marks all the receipts from the relation as unread
    def mark_as_unread(options={})
      update_receipts({:is_read => false}, options)
    end

    #Marks the receipt as deleted
    def mark_as_deleted(options={})
      update_receipts({:deleted => true}, options)
    end

    #Marks the receipt as not deleted
    def mark_as_not_deleted(options={})
      update_receipts({:deleted => false}, options)
    end


    def update_receipts(updates, options={})
      ids = where(options).map { |rcp| rcp.id }
      unless ids.empty?
        sql = ids.map { "#{table_name}.id = ? " }.join(' OR ')
        conditions = [sql].concat(ids)
        Alerter::Receipt.where(conditions).update_all(updates)
      end
    end
  end


  #Marks the receipt as deleted
  def mark_as_deleted
    update_attributes(:deleted => true)
  end

  #Marks the receipt as not deleted
  def mark_as_not_deleted
    update_attributes(:deleted => false)
  end

  #Marks the receipt as read
  def mark_as_read
    update_attributes(:is_read => true)
  end

  #Marks the receipt as unread
  def mark_as_unread
    update_attributes(:is_read => false)
  end

  #Returns if the participant has read the Notification
  def is_unread?
    !is_read
  end

end