class Hash

  # Return self as symbolized keys hash
  def symbolize_keys
    self.dup.inject({}) do |hsh, (k,v)|
      hsh[k.to_sym] = (v.respond_to?(:symbolize_keys) ? v.symbolize_keys : v)
      hsh
    end
  end

  # Replace self with symbolized keys hash
  def symbolize_keys!
    self.replace(self.symbolize_keys)
  end

end