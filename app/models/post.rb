module PostTransitions
  extend self  # Allows for private in-module methods

  attr_accessor :transitions, :states, :actions

  self.transitions = {:draft     => {:save       => :draft,
                                     :done       => :completed,
                                     :trash      => :tossed},
                      :completed => {:publish    => :published,
                                     :edit       => :draft,
                                     :trash      => :tossed},
                      :published => {:unpublish  => :completed,
                                     :trash      => :tossed},
                      :tossed    => {:restore    => :draft,
                                     :trash      => :tossed}}
  self.states = transitions.keys
  self.actions = [:save, :done, :trash, :publish, :unpublish, :edit, :restore]

  def good_state?(state)
    self.states.member? state
  end

  def good_action?(action)
    self.actions.member? action
  end

  def transition(state, action)
    self.transitions[state][action]
  end
  
end

class Post < ActiveRecord::Base
  attr_accessible :body, :published_at, :slug, :state, :title

end
