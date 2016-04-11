class Category < ActiveRecord::Base
  has_many :questions

  # @category.shows
  # Returns instances of Show where @category appeared
  def shows
    self.questions.collect {|question| question.round.show}.uniq
  end

  # Scope
  # Category.most_common(5)
  # Returns 5 most common categories
  # IMPORTANT: categories of questions revealed!
  def self.most_common(number=1)
    order('questions_count DESC').limit(number)
  end
end
