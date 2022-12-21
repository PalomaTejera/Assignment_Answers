#From Lesson 7 - Task solution part B
def fetch(uri_str)  # this "fetch" routine does some basic error-handling.  
    address = URI(uri_str)
    response = Net::HTTP.get_response(address)
    case response
      when Net::HTTPSuccess then
        return response  # return that response object
      else
        raise Exception, "Something went wrong... the call to #{uri_str} failed; type #{response.class}"
        response = false
        return response  # now we are returning False
    end 
end
  