class User
  include Mongoid::Document
  include Mongoid::Timestamps
  # include Mongoid::Geospatial
  include Mongoid::Attributes::Dynamic
  attr_accessor :password
  has_one :session, dependent: :destroy
  mount_uploader :avatar, AttachmentUploader
  before_save :encrypt_password
  after_create :create_session_record

  field :email, type: String, default: ""
  validates_uniqueness_of :email
  # validates_format_of :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i, :message => "Please Enter a Valid Email Address."
  validates_presence_of :password, :on => :create
  field :encrypted_password, type: String, default: ""
  field :salt, type: String, default: ""

  # Delegate
  delegate :url, :size, :path, to: :avatar
  # field :attached_item_id, type: Integer
  # field :attached_item_type, type: String 
  field :avatar, type: String#, null: false
  # field :original_filename, type: String
  # Virtual attributes
  # alias_attribute :filename, :original_filename
  validates_integrity_of  :avatar
  validates_processing_of :avatar

  field :first_name, type: String
  field :last_name, type: String
  field :user_name, type: String

  def build_user_hash
    user = {id: self.id.to_s,
     email: self.email,
     created_at: self.created_at
    }
    user[:first_name] = self.first_name if self.first_name
    user[:last_name] = self.last_name if self.last_name
    user[:user_name] = self.user_name if self.user_name
    user[:normal_avatar] = self.avatar.url if self.avatar
    user[:thumb_avatar] = self.avatar.thumb.url if self.avatar
    return user
  end

  def self.search(search)
    search = search.split(" ")
    if search.count == 1
      User.or(
        {"first_name": /.*#{search.first}.*/i}, 
        {"last_name": /.*#{search.first}.*/i}, 
        {"user_name": /.*#{search.first}.*/i}
        )
    else
      User.or(
        {"first_name": /.*#{search.first}.*/i}, 
        {"last_name": /.*#{search.first}.*/i}, 
        {"last_name": /.*#{search.last}.*/i}, 
        {"user_name": /.*#{search.last}.*/i}, 
        {"user_name": /.*#{search.first}.*/i}
        )
    end
  end

  def self.build_search_hash(user)
    user_hash = {id: user.id.to_s,
     first_name: user.first_name,
     last_name: user.last_name,
     email: user.email,
     avatar: user.avatar.url,
     user_name: user.user_name,
     created_at: user.created_at
    }
    # if !current_user.blank?
    #   user_hash[:friendship_status] = current_user.first.followed_users.include?(user.id.to_s) ? 
    #      "Is already a friend" : (user.pending_friends.include?(current_user.first.id.to_s) ? 
    #       "Request Sent" : "Send Request")
    # end
    # user_hash[:like_count] = user.likes.count if user.likes
    return user_hash
  end

  def authenticate(password)
    pass = BCrypt::Engine.hash_secret(password, self.salt)
    self.encrypted_password == pass
  end

  # def self.add_location_data(user_id, coords, time_stamp)
  #   loc = UserLocation.new
  #   loc.user_id = user_id
  #   loc.coords = coords.split(",")
  #   loc.time_stamp = time_stamp
  #   loc.save(validate: false)
  #   return loc
  # end

# Place all this in the area_watcher model
  # # ---------- Create and update Area Watcher ----------- Begin
  # def area_watcher(coords)
  #   in_an_area = self.inside_an_area?(coords.coords)
  #   if self.area_watchers.any?
  #     update_or_create_area_watcher(in_an_area, self, coords)
  #   elsif in_an_area.first == true
  #     # TODO update this, 
  #     new_area_watcher(self.id, in_an_area.last.id, coords.time_stamp, "full_visit")
  #   else
  #     return true
  #   end
  # end

  # def update_or_create_area_watcher(in_an_area, user, coords)
  #   last_watcher = user.area_watchers.order_by(created_at: :desc).first
  #   if !last_watcher.finished
  #     if last_watcher.pre_selection_stage == true
  #       update_pre_selected(last_watcher, coords)
  #     else
  #       inside_last_area_or_not(last_watcher, coords, in_an_area, user)
  #     end
  #   elsif in_an_area.first == true
  #     next_area_watcher_setup(last_watcher, coords, user, in_an_area )
  #   else
  #     return true
  #   end
  # end

  # def update_pre_selected(last_watcher, coords)
  #   if last_watcher.area.has_coords? coords
  #     if last_watcher.updated_at < 60.seconds.ago
  #       last_watcher.destroy
  #     else
  #       last_watcher.pre_selection_count += 1
  #       if last_watcher.pre_selection_count == 3
  #         last_watcher.pre_selection_stage = false
  #       end
  #       last_watcher.save
  #     end
  #   else
  #     last_watcher.destroy
  #   end
  # end

  # def inside_last_area_or_not(last_watcher, coords, in_an_area, user)
  #   if last_watcher.area.has_coords? coords
  #     update_last_watcher_in_area(last_watcher, in_an_area, coords, user)
  #   else
  #     locs = previous_user_coord(user, 0, 3)
  #     update_last_watcher_not_in_an_area(locs, last_watcher, in_an_area, coords, user)
  #   end
  # end

  # def update_last_watcher_in_area(last_watcher, in_an_area, coords, user)
  #   if last_watcher.updated_at < 90.seconds.ago
  #     make_watcher_a_visit(last_watcher, in_an_area, user, coords)
  #   else
  #     last_watcher.touch
  #   end
  # end

  # def update_last_watcher_not_in_an_area(locs, last_watcher, in_an_area, coords, user)
  #   if last_watcher.updated_at < 90.seconds.ago
  #     make_watcher_a_visit(last_watcher, in_an_area, user, coords)
  #   elsif !last_watcher.area.has_coords? locs
  #     complete_watcher(last_watcher, last_watcher.visit_type)
  #   else
  #     last_watcher.touch
  #   end
  # end

  # def make_watcher_a_visit(last_watcher, in_an_area, user, coords)
  #   # Doesn't seem right, Need to come back to this
  #   complete_watcher(last_watcher, 
  #     last_watcher.visit_type ==  "full_visit" ? "single_visit" : "continued_visit"
  #     )
  #   if in_an_area.first == true
  #     next_area_watcher_setup(last_watcher, coords, user, in_an_area )
  #   end
  # end

  # def complete_watcher(last_watcher, visit)
  #   last_watcher.update_attributes(
  #     last_coord_time_stamp: last_watcher.updated_at, 
  #     finished: true,
  #     visit_type: visit,
  #   )
  # end

  # def new_area_watcher(user_id, area_id, time_stamp, visit_type)
  #   a = AreaWatcher.new
  #   a.user_id = user_id
  #   a.area_id = area_id
  #   a.first_coord_time_stamp = time_stamp
  #   a.visit_type = visit_type
  #   a.save
  # end

  # def next_area_watcher_setup(last_watcher, coords, user, in_an_area )
  #   if is_a_continued_visit?(last_watcher, coords, in_an_area, user)
  #     new_area_watcher(user.id, in_an_area.last.id, coords.time_stamp, "continued_visit")
  #   elsif is_a_visit?(last_watcher, coords, in_an_area, user)
  #     new_area_watcher(user.id, in_an_area.last.id, coords.time_stamp, "single_visit")
  #   else
  #     new_area_watcher(user.id, in_an_area.last.id, coords.time_stamp, "full_visit")
  #   end
  # end

  # # 1) Check to see if the last area watcher was a single or continued visit
  # # 2) Was the last area watcher updated in the last 4 hours
  # # 3) Is the current area the user is in, the same as the previous area
  # # 3) Does the current area have the users previous 2 coords
  # def is_a_continued_visit?(last_watcher, coords, in_an_area, user)
  #   ["single_visit", "continued_visit"].include?(last_watcher.visit_type) &&
  #   last_watcher.last_coord_time_stamp > 4.hours.ago && 
  #   in_an_area.last.id == last_watcher.area_id && 
  #   in_an_area.last.has_coords?(previous_user_coord(user, 1, 2))
  # end

  # def is_a_visit?(last_watcher, coords, in_an_area, user)
  #   if last_watcher.visit_type == "continued_visit"
  #     last_watcher.last_coord_time_stamp > 6.hours.ago && 
  #     in_an_area.last.id == last_watcher.area_id && 
  #     in_an_area.last.has_coords?(previous_user_coord(user, 1, 2))
  #   elsif last_watcher.visit_type == "single_visit"
  #     last_watcher.last_coord_time_stamp > 12.hours.ago &&
  #     in_an_area.last.id == last_watcher.area_id && 
  #     in_an_area.last.has_coords?(previous_user_coord(user, 1, 2))
  #   else
  #     false
  #   end
  # end

  # def previous_user_coord(user, offset = 1, take = 1)
  #   user.user_locations.order_by(time_stamp: :desc).offset(offset).limit(take).to_a
  # end

  # def inside_an_area?(coords)
  #  # coords = Mongoid::Geospatial::Point object
  #  if coords.is_a? Array
  #    area = Area.where(
  #      area_profile: {
  #        "$geoIntersects" => {
  #          "$geometry"=> {
  #            type: "Point",
  #            coordinates: [coords.first, coords.last]
  #          }
  #        }
  #      },
  #      :level.nin => ["L0"],
  #      :level.in => ["L1", "L2"]
  #      )
  #  else
  #    area = Area.where(
  #      area_profile: {
  #        "$geoIntersects" => {
  #          "$geometry"=> {
  #            type: "Point",
  #            coordinates: [coords.x, coords.y]
  #          }
  #        }
  #      },
  #      :level.nin => ["L0"],
  #      :level.in => ["L1", "L2"]
  #      )
  #  end
  #  # area = Area.where(title: "Arcadia on 49th")
  #  if area.any?
  #     if area.count > 1
  #       l1 = area.to_a.find {|a| a.level == 'L2'}
  #       return true, l1
  #     else
  #       return true, area.first     
  #     end
  #  else
  #    return false, ""
  #  end
  # end
  # ---------- Create and update Area Watcher ----------- END
  def create_session_record
    require 'json_web_token'
    sesh = Session.new
    sesh.user_id = self.id 
    sesh.jwt = JsonWebToken.encode({user_id: self.id.to_s})
    sesh.save
  end
  private

    def encrypt_password
      if password.present?
        self.salt = BCrypt::Engine.generate_salt
        self.encrypted_password = BCrypt::Engine.hash_secret(password, self.salt)
      end
    end

    def avatar_size_validation
      errors[:avatar] << "should be less than 500KB" if avatar.size > 100.5.megabytes
    end
end



