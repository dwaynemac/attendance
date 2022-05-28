class ApplicationJob

  attr_accessor :attributes

  def initialize(attributes = {})
    @attributes = attributes
  end

  def already_queued?
    Delayed::Job.where("handler = ?", self.to_yaml)
                .where("attempts < ?", Delayed::Worker.max_attempts)
                .exists?
  end

  def queue
    unless already_queued?
      Delayed::Job.enqueue self
    end
  end

end
