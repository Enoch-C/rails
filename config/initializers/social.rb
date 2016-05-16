class String
  def to_url
    self.downcase.gsub(" ","-")
  end
end
