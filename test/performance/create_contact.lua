-----------------------------------------------------------------------------------------
-- Create Contact Load Test
--
-- Sample invocation:
-- wrk -s test/performance/create_contact.lua -d10 -t4 -c4 http://localhost:8888/contact/
-----------------------------------------------------------------------------------------


-- NOTE: each wrk thread has an independent Lua scripting
-- context and thus there will be one counter per thread
counter = 0 

wrk.headers["Content-Type"] = "application/json"

request = function() 
  counter = counter + 1
  wrk.body = '{"firstName": "Test", "lastName": "Newuser'..counter..'"}'
  return wrk.format("POST", nil, nil, body)
end
