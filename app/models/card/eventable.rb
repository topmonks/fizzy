module Card::Eventable
  extend ActiveSupport::Concern

  include ::Eventable

  included do
    before_create { self.last_active_at ||= created_at || Time.current }

    before_save -> { @description_changed = rich_text_description&.body_changed? }
    after_save :track_title_change, if: :saved_change_to_title?
    after_save :track_description_change, if: -> { @description_changed }
  end

  def event_was_created(event)
    transaction do
      create_system_comment_for(event)
      touch_last_active_at unless was_just_published?
    end
  end

  def touch_last_active_at
    # Not using touch so that we can detect attribute change on callbacks
    update!(last_active_at: Time.current)
  end

  private
    def should_track_event?
      published? && Current.user.present?
    end

    def track_title_change
      if title_before_last_save.present?
        track_event "title_changed", particulars: { old_title: title_before_last_save, new_title: title }
      end
    end

    def track_description_change
      @description_changed = false
      track_event "description_changed"
    end

    def create_system_comment_for(event)
      SystemCommenter.new(self, event).comment
    end
end
