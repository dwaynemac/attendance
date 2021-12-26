require "padma_crm_api"

# encoding: UTF-8
#
# LEE de crm con formato antiguo
# ESCRIBE a crm con formato NUEVO
#
class CrmLegacyContact < LogicalModel

  def self.crm_host
    if Rails.env.development?
      "localhost:3000"
    else
      "crm.padm.am"
    end
  end

  use_hydra Contacts::HYDRA

  set_resource_url crm_host,"/contacts_api/v0/contacts"
  set_api_key :app_key, ENV["crm_contacts_v0_api_key"]

  attribute :_id
  attribute :crm_padma_id
  attribute :first_name
  attribute :last_name
  attribute :gender
  attribute :estimated_age
  attribute :estimated_age_on
  attribute :avatar
  attribute :status
  attribute :local_status # will only be setted if #find specifies account_name
  attribute :local_statuses # array of all local statuses
  attribute :last_seen_at # will only be setted if #find specifies account_name
  attribute :last_local_status
  attribute :local_teacher
  attribute :local_teachers # array of all local teachers
  attribute :global_teacher_username
  attribute :level
  attribute :coefficient # will only be setted if #find specifies account_name
  attribute :coefficients_counts
  attribute :owner_name
  attribute :linked # will only be setted if #find specifies account_name
  attribute :check_duplicates
  attribute :email # Primary email (contact attribute)
  attribute :telephone # Primary telephone (contact attribute)
  attribute :in_active_merge
  attribute :observation
  attribute :in_professional_training
  attribute :professional_training_level
  attribute :derose_id
  attribute :kshema_id
  attribute :slug
  attribute :first_enrolled_on

  attribute :membership
  attribute :time_slots

  # setter for adding tags on creation or update
  attribute :new_tag_names

  has_many :contact_attributes
  has_many :attachments
  has_many :tags
  has_many :history_entries

  self.enable_delete_multiple = true

  validates_presence_of :first_name
  validates_inclusion_of :gender, in: %W(male female non_binary), allow_blank: true
  validates_numericality_of :estimated_age, allow_blank: true

  validates_associated :contact_attributes
  validates_associated :attachments
  validates_associated :tags

  def json_root
    :contact
  end

  def self.find(id, params = {})
    params[:legacy_format] = true
    super(id, params)
  end

  def self.paginate(options = {})
    options[:legacy_format] = true
    super(options)
  end

  def update(params)
    if id
      attributes = params[:contact]
      options = params.reject { |k,v| k==:contact }
      PadmaCrmApi.new.update_contact(
        id,
        attributes,
        options
      )
    end
  end

  ##
  # Search is same as paginate but will make POST /search request instead of GET /index
  #
  # Parameters:
  #   @param options [Hash].
  #   Valid options are:
  #   * :page - indicated what page to return. Defaults to 1.
  #   * :per_page - indicates how many records to be returned per page. Defauls to 9999
  #   * all other options will be sent in :params to WebService
  #
  # Usage:
  #   Person.search(:page => params[:page])
  def self.search(options = {})
    options[:page] ||= 1
    options[:per_page] ||= 9999
    options[:legacy_format] = true

    options = self.merge_key(options)

    response = Typhoeus.post(self.resource_uri+'/search', body: options)

    if response.success?
      log_ok(response)
      result_set = self.from_json(response.body)

      # this paginate is will_paginate's Array pagination
      return Kaminari.paginate_array(
        result_set[:collection],
        {
          :total_count=>result_set[:total],
          :limit => options[:per_page],
          :offset => options[:per_page] * ([options[:page], 1].max - 1)
        }
      )
    else
      log_failed(response)
      return nil
    end
  end


  def create(params)
    raise NotImplementedError
  end
  def destroy(params = nil)
    raise NotImplementedError
  end

  TIMEOUT = 5500 # miliseconds
  PER_PAGE = 9999

  VALID_LEVELS = %W(aspirante sádhaka yôgin chêla graduado asistente docente maestro)
  validates_inclusion_of :level, in: VALID_LEVELS, allow_blank: true

  VALID_STATUSES = %W(student former_student prospect)
  validates_inclusion_of :local_status, in: VALID_STATUSES, allow_blank: true
  validates_inclusion_of :status, in: VALID_STATUSES, allow_blank: true

  VALID_COEFFICIENTS = %W(unknown fp pmenos perfil pmas)
  validates_inclusion_of :coefficient, in: VALID_COEFFICIENTS, allow_blank: true

  def id
    self._id
  end

  def id= id
    self._id = id
  end

  # @argument [Hash] options
  # @return [Array<ActivityStream::Activity>]
  def activities(options={})
    ActivityStream::Activity.paginate(options.merge({where: {target_id: self.id, target_type: 'Contact'}}))
  end

  def linked?
    self.linked
  end

  def persisted?
    self._id.present?
  end

  def in_professional_training?
    self.in_professional_training
  end

  ContactAttribute::AVAILABLE_TYPES.each do |type|
    define_method(type.to_s.pluralize) do
      if self.contact_attributes
        self.contact_attributes.select{ |attr| attr && attr.is_a?(type.to_s.camelize.constantize)}.sort_by{|x| x.primary ? 0 : 1 }
      end
    end
  end

  def facebook_id
    self.contact_attributes.select{|attr| attr.is_a?(SocialNetworkId) && attr.category == "facebook"}.first if self.contact_attributes
  end

  def mobiles
    self.contact_attributes.select{|attr| attr.is_a?(Telephone) && attr.category == "mobile"} if self.contact_attributes
  end

  def non_mobile_phones
    self.contact_attributes.select{|attr| attr.is_a?(Telephone) && attr.category != "mobile"} if self.contact_attributes
  end

  def former_student_at
    local_statuses.select{|s|s['value']=='former_student'}.map{|s|s['account_name']} if self.local_statuses
  end

  def prospect_at
    local_statuses.select{|s|s['value']=='prospect'}.map{|s|s['account_name']} if self.local_statuses
  end

  # Returns age in years of the contact or nil if age not available
  # @return [Integer/NilClass]
  def age
    birthday = self.date_attributes.select{|da| da.is_a_complete_birthday?}[0]
    now = Time.now.utc.to_date
    if birthday
      now.year - birthday.year.to_i - ((now.month > birthday.month.to_i || (now.month == birthday.month.to_i && now.day >= birthday.day.to_i)) ? 0 : 1)
    else
      nil
    end
  end

  def check_duplicates
    @check_duplicates || false
  end

  # @return [Array<PadmaContac>] posible duplicates of this contact
  def possible_duplicates
    possible_duplicates = []
    unless self.errors[:possible_duplicates].empty?
      self.errors[:possible_duplicates][0][0].each do |pd|
        possible_duplicates << PadmaContact.new(pd) #"#{pd["first_name"]} #{pd["last_name"]}"
      end
    end
    possible_duplicates
  end

  # Returns total amount of coefficients this contact has assigned
  # @return [ Integer ]
  def coefficients_total
    self.coefficients_counts.nil?? 0 : self.coefficients_counts.inject(0){|sum,key_value| sum += key_value[1]}
  end

  def in_active_merge?
    self.in_active_merge
  end

  DEFAULT_BATCH_SIZE = 500
  ##
  #
  # It's slower than .search BUT if contacts-ws is timing out
  # this will work because requests are smaller.
  #
  # @param search_options [Hash]
  # @param batch_options [Hash]
  #
  # @option search_options any option valid for .search
  # @option batch_options [Intger] batch_size - Size of batches
  # @option batch_options [Integer] total - Total amount of contacts.
  #         To avoid making an extra call for counting
  def self.batch_search(search_options = {}, batch_options = {})
    search_options[:legacy_format] = true
    batch_options[:batch_size] ||= DEFAULT_BATCH_SIZE
    ret = nil

    total = batch_options[:total] || self.count_by_post(search_options)
    if total
      ret = []
      (total.to_f/batch_options[:batch_size]).ceil.times do |i|
        self.async_search(search_options.merge(per_page: batch_options[:batch_size], page: i+1)) do |page_elements|
          if page_elements
            ret += page_elements
          end
        end
      end
    end
    self.hydra.run
    ret.sort!{|a,b| a.first_name <=> b.first_name} if ret
    return ret
  end

  def self.async_search(options={})
    options[:page] ||= 1
    options[:per_page] ||= 9999
    options[:legacy_format] = true

    options = self.merge_key(options)

    request = Typhoeus::Request.new(
      resource_uri('search'),
      method: :post,
      body: options,
      headers: default_headers
    )
    request.on_complete do |response|
      if response.code >= 200 && response.code < 400
        log_ok(response)

        result_set = self.from_json(response.body)

        # this paginate is will_paginate's Array pagination
        collection = Kaminari.paginate_array(
          result_set[:collection],
          {
            :total_count=>result_set[:total],
            :limit => options[:per_page],
            :offset => options[:per_page] * ([options[:page], 1].max - 1)
          }
        )

        yield collection
      else
        log_failed(response)
      end
    end
    self.hydra.queue(request)
  end

  # @see count
  # Same as count by will make a POST request instead of GET request
  def self.count_by_post(options)
    options[:page] = 1
    options[:per_page] = 1
    options[:legacy_format] = true

    options = self.merge_key(options)

    response = Typhoeus.post(self.resource_uri+'/search', body: options)
    if response.success?
      log_ok(response)
      result_set = self.from_json(response.body)
      return result_set[:total]
    else
      log_failed(response)
      return nil
    end
  end

end
