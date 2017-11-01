require 'HTTParty'
require 'ap'

class EdamamApiWrapper

  BASE_URL = "https://api.edamam.com/search?"
  APP_KEY = ENV["EDAMAM_KEY"]
  APP_ID = ENV["EDAMAM_ID"]

  SEARCH_LENGTH = 10
  MINIMUM_BAR = %w(label uri image ingredientLines)
  RECIPE_URL = "http://www.edamam.com/ontologies/edamam.owl%23recipe_"

  def self.search(query, options = { } )
    options[:app_id] ||= APP_ID
    options[:app_key]||= APP_KEY
    options[:hits] ||= SEARCH_LENGTH

    url = BASE_URL + "q=#{query}" + "&app_id=#{options[:app_id]}" + "&app_key=#{options[:app_key]}" + "&to=#{options[:hits]}"

    response = HTTParty.get(url)

    if response["hits"]
      recipe_hits = response["hits"].map do |hit|
        if self.complete?(hit["recipe"])
          Recipe.new(
            hit["recipe"]["label"],
            hit["recipe"]["uri"],
            hit["recipe"]["image"],
            hit["recipe"]["ingredientLines"],
            external_url: hit["recipe"]["url"],
            source: hit["recipe"]["source"]
          )
        end
      end
      return recipe_hits
    else
      return []
    end
  end

  def self.find_recipe(mini_uri, options = { })
    options[:app_id] ||= APP_ID
    options[:app_key] ||= APP_KEY

    url = BASE_URL + "r=" + RECIPE_URL + mini_uri + "&app_id=#{options[:app_id]}" + "&app_key=#{options[:app_key]}"

    response = HTTParty.get(url)

    if response[0]
      if self.complete?(response[0])
        recipe = Recipe.new(
          response[0]["label"],
          response[0]["uri"],
          response[0]["image"],
          response[0]["ingredientLines"],
          external_url: response[0]["url"],
          source: response[0]["source"]
        )
      end
      return recipe
    else
      return "oops"
    end
  end

  def self.complete?(hash)
    MINIMUM_BAR.each do |bar|
      unless hash[bar]
        return false
      end
      return true
    end

  end
end
