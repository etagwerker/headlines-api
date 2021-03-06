require './database'
require './source'
require './reaction'

class News < ActiveRecord::Base
  belongs_to :source
  has_many :reaction
  delegate :name, :to => :source, :prefix => true

  def self.search_news_by_title(search)
    News.where('LOWER(title) LIKE ?', "%#{search.downcase}%").order('date DESC').limit(200)
  end

  def self.search_news_by_title_with_reactions(search)
    News.search_news_by_title(search).map do |i|
      tmp = i.as_json
      tmp['source_name'] = i.source_name
      tmp['reactions'] = Reaction.raw_reactions_by_news_id(i.news_id)
      tmp
    end
  end

  def self.popular_news
    News
      .select('news.*, count(reactions.reaction_id) as total_reactions')
      .joins(:reaction)
      .group('news.news_id')
      .having('total_reactions > 0')
      .order('date DESC')
      .limit(200)
  end
end
