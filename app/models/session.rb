class Session
	include Mongoid::Document
	include Mongoid::Timestamps
	belongs_to :user, index: true
	field :jwt, type: String
	field :archived_at, type: DateTime, default: nil
	field :device, type: String #, default: "Mobile"

end