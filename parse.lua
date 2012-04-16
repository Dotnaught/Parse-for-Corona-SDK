local Parse = {}
-- This module shows how to communicate with Parse, a back-end storage service.
-- It builds upon sample code posted to Ansca Mobile's Corona forum:
-- https://developer.anscamobile.com/forum/2011/09/27/parse-backend
-- For documentation of Parse's REST API, see: https://www.parse.com/docs/rest#general
-- For debugging REST communication, http://www.hurl.it is a useful resource
-- You're on your own with this code but if I'll try to answer questions, support[at]lot49.com
-- This software is available under MIT License


--Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
--to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
--and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

--The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
--IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
--SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


value = require ("json")
		local url = require("socket.url") -- http://w3.impa.br/~diego/software/luasocket/url.html

        --Parse data fields
       
		local playerEmail = {}
		playerEmail.email = nil
		
		local request = nil
		Parse.request = request
		
		local baseUrl = "https://api.parse.com/1/"
		local class = {}
		class.users = "users"
		class.login = "login"
		class.reset = "requestPasswordReset"
		--define other object classes as necessary
		--class.game = "classes/game"
        
        --sign up with Parse.com to obtain Application ID and REST API Key
        local headers = {}
        headers["X-Parse-Application-Id"]  = "xxxxx" -- your Application-Id
        headers["X-Parse-REST-API-Key"]    = "xxxxx" -- your REST-API-Key
		headers["X-Parse-Session-Token"]   = nil -- session token for altering User object
        
        local params = {}
        params.headers = headers

	
		--get from player input or local storage
		local AccountSetup = {
								username = nil,
								password = nil,
								email = nil
								}
        Parse.AccountSetup = AccountSetup

		local LocalAccount = {  	
										username = nil,
										password = nil,
										email = nil,
										emailVerified = false, 	-- read-only response field
										objectId = nil,        	-- read-only response field
										createdAt = nil,       	-- read-only response field
										updatedAt = nil,       	-- read-only response field
										sessionToken = nil,     -- read-only response field
										experience = nil,
								        credits = nil
								        -- define additional fields as necessary
							}
	   Parse.LocalAccount = LocalAccount
	

	
	  local updateData = {["credits"] = 100}
	  
	
	   Parse.updateData = updateData	
	
      
     
       local function networkListener( event )
                		local response = nil
                        print (request .. " response: ", event.response)
                        if ( event.isError ) then
                                        print( "Network error!")
                        else
										print ("Status code: ", event.status)
                                        response = value.decode ( event.response )

										if response["error"] then
										print (response["error"])
											if (response["code"] == 101 and request == "login") then
											 print ("Invalid login parameters")
											end
											if (response["code"] == 202 and request == "signup") then
										    print ("Username taken")
											end
											if (response["code"] == 206 and request == "updateObj") then
										    print ("Must be logged in to update object")
											end
											
                                        else
											if (request == "signup") then
													-- pass player account info to LocalAccount
												    for k,v in pairs(AccountSetup) do
													LocalAccount[k] = v	
													end
													-- pass parse response to LocalAccount
													for k,v in pairs(response) do
													LocalAccount[k] = v
													end
													-- set playeremail table in case password reset needs to be called
													playerEmail.email = LocalAccount["email"]
												
													
											end
											
											if (request == "login") then
													for k,v in pairs(response) do
													LocalAccount[k] = v
													end
													--set sessionToken
													headers["X-Parse-Session-Token"] = LocalAccount.sessionToken
						
											end
												if (request == "updateObj") then
													--get response
													for k,v in pairs(response) do
														LocalAccount[k] = v
													end
													--now update
													for k,v in pairs (updateData) do
													LocalAccount[k] = v	
													end
												end
											
											
											if (request == "updateObj" or request == "getObj") then
												for k,v in pairs(response) do
													LocalAccount[k] = v
												end
											
											end
											
											if (request == "findObj") then
													
												--parse table returned in response["results"][1]
												if (response["results"][1]) then
													for k,v in pairs(response["results"][1]) do
													LocalAccount[k] = v
													print ("k", k, "v", v)
													end
												else
													print ("Object not found")
												end

											end
											
											
											if (request == "deleteObj") then
												    --delete local object
													for k,v in pairs(LocalAccount) do
													LocalAccount[k] = nil	
													end
											end
										
                                       end
                                        
                        end

						
						--reset reference to calling function
						request = nil
						
						print ("###")
						print ("LocalAccount: ")
						for k,v in pairs(LocalAccount) do
							print (k, ":", v)
						end
						print ("###")
					
						
        end

		local function getStoredUsername ()
		local path = system.pathForFile( "usr.txt", system.DocumentsDirectory )

			-- io.open opens a file at path. returns nil if no file found
		local file, err = io.open( path, "r" )

			if (file) then
			   	local storedName = file:read( "*a" )
			   	return storedName
			else
				print ("Failed: ", err)
				return nil
			end
		
		end
		Parse.getStoredUsername = getStoredUsername

        local function signup (obj)
				if (not obj.username or not obj.password or not obj.email) then
				print ("Missing login data")
				else
				headers["Content-Type"]  = "application/json"
                params.body = value.encode ( obj )
				request = "signup"
                network.request( baseUrl .. class.users, "POST", networkListener,  params)
				end
        end
		Parse.signup = signup

		local function login (obj)
			if (not obj.username or not obj.password) then	
			print ("No data available for login")
			
			--check for account verification
			--elseif (not obj.emailVerified) then
			--print ("Cannot login. Email address not verified.")
			
			else
			   headers["Content-Type"] = "application/x-www-form-urlencoded"
			   params.body = nil
			   local query = "?username=" .. obj.username .. "&password=" .. obj.password
			   request = "login"
               network.request( baseUrl .. class.login .. query, "GET", networkListener, params)
		   	end
			   
		end
        Parse.login = login
 

       local function resetPassword (obj)
					if (obj.email) then
					headers["Content-Type"] = "application/json"
					request = "resetPassword"
	                params.body = value.encode ( obj )
	                network.request( baseUrl .. class.reset, "POST", networkListener,  params)
					else
					print ("No email available")
					end
	    end
		Parse.resetPassword = resetPassword
        
        local function updateObj (obj, data)
                if (obj.objectId) then
						headers["Content-Type"] = "application/json"
                        params.body = value.encode ( data )
						request = "updateObj"
						print (baseUrl .. class.users .. "/" .. obj.objectId)
							for k,v in pairs(data) do
								print ("updateObj: ", k, ":", v)
							end
                        network.request( baseUrl .. class.users .. "/" .. obj.objectId, "PUT", networkListener,  params)

				else
				print ("No object to update")
                end
        end
		Parse.updateObj = updateObj
        
        local function deleteObj (obj)
                if (obj.objectId) then 
				headers["Content-Type"] = "application/json"
				request = "deleteObj"
				network.request( baseUrl .. class.users .. "/" .. obj.objectId, "DELETE", networkListener,  params) 
				else
				print ("No object to delete")
				end
                
        end
		Parse.deleteObj = deleteObj
        
        local function getObj (obj)
                if (obj.objectId) then 
				headers["Content-Type"] = "application/json"
				params.body = nil
				request = "getObj"
				network.request( baseUrl .. class.users .. "/" .. obj.objectId, "GET", networkListener,  params) 
				print (baseUrl .. class.users .. "/" .. obj.objectId)
				else
				print ("Not logged in.")
				end
        end
		Parse.getObj = getObj

		local function findObj (obj)
				local storedName = getStoredUsername()
				if (not obj.username and not storedName) then
					print ("Not logged in.")
					return
			    elseif (not obj.username and storedName) then
				   obj.username = storedName
				   print ("Got stored name")
				elseif (obj.username and storedName and obj.username ~= storedName) then
					--search updated name
					obj.username = storedName
				end
				print ("obj.username: ", obj.username) 
		    		--find object by username when objectId is not known
					headers["Content-Type"] = "application/json"
					params.body = nil
					local table = {}
					--find this key/value pair
					table.username = obj.username
					local string = "?where=" .. url.escape(value.encode(table))
					print ("LOOKING FOR: ", baseUrl .. class.users .. string)
					request = "findObj"
					network.request( baseUrl .. class.users .. string, "GET", networkListener,  params)
					print (baseUrl)

		end
		Parse.findObj = findObj
        
        -- set up buttons
        
        
        local function buttonHandler ( event )
        
                local method = event.target.method
                
                if event.phase == "ended" then
						
                        --pass other objects to these functions if data is not on user object
					    if method == "signup" then signup (AccountSetup)
                        elseif method == "login" then login (LocalAccount) 
						elseif method == "getObj" then getObj (LocalAccount)
						elseif method == "findObj" then findObj (LocalAccount)
                        elseif method == "updateObj" then updateObj (LocalAccount, updateData)
                        elseif method == "deleteObj" then deleteObj (LocalAccount) 
						elseif method == "resetPassword" then resetPassword (playerEmail) 
						end
                end
				return true
        end
        
        local buttons = { "signup", "login", "getObj", "findObj", "updateObj", "deleteObj",  "resetPassword" }
        
        for i=1,#buttons do
                local b = display.newText ( buttons[i], 30, 24*i, native.systemFontBold, 12)
                b.method = buttons[i]
                b:addEventListener ( "touch", buttonHandler )
        end

return Parse


