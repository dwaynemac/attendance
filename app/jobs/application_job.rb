class ApplicationJob

  attr_accessor :attributes

  def initialize(attributes = {})
    @attributes = attributes
  end

  def perform
    # child class should implement this method
    raise NotImplementedError
  end

  # hay jobs iguales a mí pendientes
  def already_queued?
    duplicate_jobs.where("attempts < ?", Delayed::Worker.max_attempts).exists?
  end

  # otros jobs iguales a mí
  def duplicate_jobs
    Delayed::Job.where("handler = ?", self.to_yaml)
  end

  def pending_duplicate_job
    duplicate_jobs.where("attempts < ?", Delayed::Worker.max_attempts).first
  end

  # Encola el job. Si YA estaba encolado retorna el job existente
  # @return [Delayed::Job]
  def queue
    pending_duplicate_job || Delayed::Job.enqueue(self)
  end

  # Otros jobs duplicados al que doy por parámetro
  # @param [Delayed::Job] delayed_job
  # @return [ActiveRecord::Relation]
  def self.duplicate_jobs_for(delayed_job)
    Delayed::Job.where("handler = ?", delayed_job.handler).where.not(id: delayed_job.id)
  end

  def self.clean_queue_of_duplicates
    Delayed::Job.find_each do |dj|
      begin dj.reload rescue next end # el job ya fue eliminado porque estaba dupliacado
      duplicate_jobs_for(dj).delete_all
    end
  end
end
