module PostTransitions
  extend self  # Allows for private in-module methods

  @@transitions = {:draft     => {:done       => :completed,
                                  :trash      => :tossed},
                   :completed => {:publish    => :published,
                                  :edit       => :draft,
                                  :trash      => :tossed},
                   :published => {:unpublish  => :completed,
                                  :trash      => :tossed},
                   :tossed    => {:restore    => :draft}}
  @@states = @@transitions.keys
  @@actions = [:save, :done, :trash, :publish, :unpublish, :edit, :restore]

  def good_state?(state)
    @@states.member?(state)
  end

  def good_action?(action)
    @@actions.member?(action)
  end

  def next_options(state)
    @@transitions[state].keys
  end

  def transition(state, action)
    @@transitions[state][action]
  end
  
end


class Post < ActiveRecord::Base
  extend FriendlyId
  include PostTransitions

  attr_accessible :body, :state, :published_at, :title, :slug
  friendly_id :title, use: [:slugged, :history]

  def state
    super.try :to_sym
  end

  def state=(value)
    super(value.to_sym)
    state 
  end

  validates :title, :presence => true 
  validates :body,  :presence => true
  validates :state, :presence => true,
                    :inclusion => { :in => @@states,
                            :message => "%{value} is not a valid state" }

  def transition!(action)
    if good_state?(self.state) and good_action?(action)
      self.state = transition(self.state, action)
    else
      puts "Either action " + action + " or state " + self.state.to_s + " were invalid"
    end
  end

  def next_states
    next_options(self.state)
  end

end
