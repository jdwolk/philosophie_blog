module PostTransitions
  extend self  # Allows for private in-module methods

  @@transitions = {:draft     => {:save       => :draft,
                                  :done       => :completed,
                                  :trash      => :tossed},
                   :completed => {:publish    => :published,
                                  :edit       => :draft,
                                  :trash      => :tossed},
                   :published => {:unpublish  => :completed,
                                  :trash      => :tossed},
                   :tossed    => {:restore    => :draft,
                                  :trash      => :tossed}}
  @@states = @@transitions.keys
  @@actions = [:save, :done, :trash, :publish, :unpublish, :edit, :restore]

  def good_state?(state)
    @@states.member?(state)
  end

  def good_action?(action)
    @@actions.member?(action)
  end

  def transition(state, action)
    @@transitions[state][action]
  end
  
end

class Post < ActiveRecord::Base
  include PostTransitions

  attr_accessible :body, :published_at, :slug, :title

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

end
