require 'test_helper'
include PostTransitions

class PostTest < ActiveSupport::TestCase
  def test_all_states_gives_tossed_for_trash_action
    expected = :tossed
    @@states.each do |s|
      assert_equal(expected, PostTransitions.transition(s, :trash))
    end
  end

  test "in draft, save action" do
    expected = :draft
    actual   = PostTransitions.transition(:draft, :save)
    assert_equal expected, actual
  end

  test "in draft, done action" do
    expected = :completed
    actual   = PostTransitions.transition(:draft, :done)
    assert_equal expected, actual
  end

  test "in completed, publish action" do
    expected = :published
    actual   = PostTransitions.transition(:completed, :publish)
    assert_equal expected, actual
  end

  test "in completed, edit action" do
    expected = :draft
    actual   = PostTransitions.transition(:completed, :edit)
    assert_equal expected, actual
  end

  test "calling mixin methods from Post" do
    p = Post.new  # starts as :draft
    expected = :draft
    actual   = p.transition(:draft, :save)
    assert_equal expected, actual
  end

end
