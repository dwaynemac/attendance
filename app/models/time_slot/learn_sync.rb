require "learn_api"

module TimeSlot::LearnSync
  extend ActiveSupport::Concern

  included do

  end

  def get_from_learn
    res = api.get(
      "/posts.json",
      {
        scope: "all",
        q: {
          padma_time_slot_id_eq: id,
        }
      }
    )
    res.try :first
  end

  def sync_to_learn
    if learn_account
      if get_from_learn
        update_on_learn
      else
        create_on_learn
      end
    end
  end

  def create_on_learn
    if learn_account && !get_from_learn
      api.post("/in_person_lives.json", {in_person_live: learn_post_attributes})
    end
  end

  def update_on_learn
    if learn_account && (learn_post = get_from_learn)
      learn_id = learn_post["id"]
      api.put("/posts/#{learn_id}.json", {post: learn_post_attributes})
    end
  end

  private

  def learn_post_attributes
    ret ={
      padma_time_slot_id: id,
      title: name,
      owner_account_id: learn_account["id"],
      slug: "padma_time_slot_#{id}",
      private_body: observations,
      visibility: "account_users",
      live_starts_at: start_at.strftime("%Y-%m-%d %H:%M").to_time, # para que esté en timezone pero sin cambiar horario
      live_ends_at: end_at.strftime("%Y-%m-%d %H:%M").to_time, # para que esté en timezone pero sin cambiar horario
      booking_wont_consume_quota: cultural_activity?,
      weekly_post: true,
      wday_0: sunday? && !unscheduled?,
      wday_1: monday? && !unscheduled?,
      wday_2: tuesday? && !unscheduled?,
      wday_3: wednesday? && !unscheduled?,
      wday_4: thursday? && !unscheduled?,
      wday_5: friday? && !unscheduled?,
      wday_6: saturday? && !unscheduled?,
    }
    if deleted?
      ret.merge({
        published_until: 1.day.ago
      })
    end
    ret
  end

  def learn_account
    api.get("/accounts.json", {q: {padma_id_eq: account.name}}).try :first
  end

  def api
    @api ||= LearnApi.new
  end



end
