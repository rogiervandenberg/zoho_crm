require 'zoho_crm/version'
require 'httparty'

module ZohoCrm
  RateLimitExceeded = Class.new(StandardError)

  class AuthenticationFailure < StandardError
    attr_reader :message
    def initialize(message)
      @message = message
    end
  end

  class Client

    AUTH_URL = "https://accounts.zoho.com/apiauthtoken/nb/create?SCOPE=ZohoCRM/crmapi&"
    GET_LEADS = "https://crm.zoho.com/crm/private/json/Leads/getRecords?"
    GET_CONTACTS = "https://crm.zoho.com/crm/private/json/Contacts/getRecords?"
    NEW_LEAD = "https://crm.zoho.com/crm/private/xml/Leads/insertRecords?"
    NEW_CONTACT = "https://crm.zoho.com/crm/private/xml/Contacts/insertRecords?"
    UPDATE_LEAD = "http://crm.zoho.com/crm/private/xml/Leads/updateRecords?"
    UPDATE_CONTACT = "http://crm.zoho.com/crm/private/xml/Contacts/updateRecords?"
    DELETE_LEAD = "http://crm.zoho.com/crm/private/xml/Leads/deleteRecords?"
    DELETE_CONTACT = "http://crm.zoho.com/crm/private/xml/Contacts/deleteRecords?"
    GET_FIELDS = "https://crm.zoho.com/crm/private/json/"
    NEW_CONTACTS = "https://crm.zoho.com/crm/private/xml/Contacts/insertRecords?"
    NEW_LEADS = "https://crm.zoho.com/crm/private/xml/Leads/insertRecords?"
    UPDATE_CONTACTS = "https://crm.zoho.com/crm/private/xml/Contacts/updateRecords?"
    UPDATE_LEADS = "https://crm.zoho.com/crm/private/xml/Leads/updateRecords?"

    def initialize(*args)
      if args.size < 1 || args.size > 2
        raise AuthenticationFailure.new("You can either use 1 or 2 arguments")
      else
        if args.size == 1
          @auth_token = args[0]
        else
          @username = args[0]
          @password = args[1]
        end
      end
    end

    def generate_auth_token
      token_url = AUTH_URL + "EMAIL_ID=#{@username}&PASSWORD=#{@password}"
      response = HTTParty.post(token_url)
      response_body = response.body
      auth_info = Hash[response_body.split(" ").map { |str| str.split("=") }]
      @auth_token = raise_auth_exception(auth_info["AUTHTOKEN"])
    end

    def retrieve_contacts(from_index, to_index)
      all_contacts = GET_CONTACTS + "authtoken=#{@auth_token}&scope=crmapi&fromIndex=#{from_index}&toIndex=#{to_index}"
      response = HTTParty.get(all_contacts)
      raise_api_exception(response)
    end

    def retrieve_leads(from_index, to_index)
      all_leads = GET_LEADS + "authtoken=#{@auth_token}&scope=crmapi&fromIndex=#{from_index}&toIndex=#{to_index}"
      response = HTTParty.get(all_leads)
      raise_api_exception(response)
    end

    def new_contact(data)
      binding.pry
      xml_data = format_contacts(data)
      formatted_data = escape_xml(xml_data)
      new_contact = NEW_CONTACT + "authtoken=#{@auth_token}&scope=crmapi&xmlData=#{formatted_data}"
      response = HTTParty.post(new_contact)
      raise_api_exception(response)
    end

    def new_lead(data)
      xml_data = format_leads(data)
      formatted_data = escape_xml(xml_data)
      new_lead = NEW_LEAD + "authtoken=#{@auth_token}&scope=crmapi&xmlData=#{formatted_data}"
      response = HTTParty.post(new_lead)
      raise_api_exception(response)
    end

    def update_contact(data, id)
      xml_data = format_contacts(data)
      formatted_data = escape_xml(xml_data)
      update_contact = UPDATE_CONTACT + "authtoken=#{@auth_token}&scope=crmapi&newFormat=1&id=#{id}&xmlData=#{formatted_data}"
      response = HTTParty.put(update_contact)
      raise_api_exception(response)
    end

    def update_lead(data, id)
      xml_data = format_leads(data)
      formatted_data = escape_xml(xml_data)
      update_lead = UPDATE_LEAD + "authtoken=#{@auth_token}&scope=crmapi&newFormat=1&id=#{id}&xmlData=#{formatted_data}"
      response = HTTParty.put(update_lead)
      raise_api_exception(response)
    end

    def delete_contact(id)
      delete_contact = DELETE_CONTACT + "authtoken=#{@auth_token}&scope=crmapi&id=#{id}"
      response = HTTParty.delete(delete_contact)
      raise_api_exception(response)
    end

    def delete_lead(id)
      delete_lead = DELETE_LEAD + "authtoken=#{@auth_token}&scope=crmapi&id=#{id}"
      response = HTTParty.delete(delete_lead)
      raise_api_exception(response)
    end

    def get_fields(module_name)
      name = module_name.capitalize
      fields = GET_FIELDS + name + "/getFields?authtoken=#{@auth_token}&scope=crmap"
      response = HTTParty.get(fields)
      raise_api_exception(response)
    end

    def multiple_new_contacts(data)
      xml_data = format_multiple_contacts(data)
      formatted_data = escape_xml(xml_data)
      new_contacts = NEW_CONTACTS + "newFormat=1&authtoken=#{@auth_token}&scope=crmapi&xmlData=#{formatted_data}"
      response = HTTParty.post(new_contacts)
      raise_api_exception(response)
    end

    def multiple_new_leads(data)
      xml_data = format_multiple_leads(data)
      formatted_data = escape_xml(xml_data)
      new_leads = NEW_LEADS + "newFormat=1&authtoken=#{@auth_token}&scope=crmapi&xmlData=#{formatted_data}"
      response = HTTParty.post(new_leads)
      raise_api_exception(response)
    end

    def update_multiple_contacts(data)
      xml_data = format_multiple_contacts(data)
      formatted_data = escape_xml(xml_data)
      update_contacts = UPDATE_CONTACTS + "authtoken=#{@auth_token}&scope=crmapi&version=4&xmlData=#{formatted_data}"
      response = HTTParty.post(update_contacts)
      raise_api_exception(response)
    end

    def update_multiple_leads(data)
      xml_data = format_multiple_leads(data)
      formatted_data = escape_xml(xml_data)
      update_leads = UPDATE_LEADS + "authtoken=#{@auth_token}&scope=crmapi&version=4&xmlData=#{formatted_data}"
      response = HTTParty.post(update_leads)
      raise_api_exception(response)
    end

    private

    def format_contacts(info)
      data = "<Contacts><row no='1'>"
      info.each do |key, value|
        data += "<FL val='" + zohoify_key(key) + "'>" + value + "</FL>"
      end
      data += "</row></Contacts>"
    end

    def format_leads(info)
      data = "<Leads><row no='1'>"
      info.each do |key, value|
        data += "<FL val='" + zohoify_key(key) + "'>" + value + "</FL>"
      end
      data += "</row></Leads>"
    end

    def format_multiple_contacts(info)
      data = "<Contacts>"
      row_num = 1
      info.each do |record|
        data += "<row no='#{row_num}'>"
        record.each do |key, value|
          data += "<FL val='" + zohoify_key(key) + "'>" + value + "</FL>"
        end
        data += "</row>"
        row_num += 1
      end
      data += "</Contacts>"
    end

    def format_multiple_leads(info)
      data = "<Leads>"
      row_num = 1
      info.each do |record|
        data += "<row no='#{row_num}'>"
        record.each do |key, value|
          data += "<FL val='" + zohoify_key(key) + "'>" + value + "</FL>"
        end
        data += "</row>"
        row_num += 1
      end
      data += "</Leads>"
    end

    def zohoify_key(key)
      key.to_s.gsub("_", " ").split.map(&:capitalize).join(' ')
    end

    def escape_xml(data)
      CGI.escape(data)
    end

    def raise_api_exception(response)
      if response["response"].nil?
        response
      elsif response["response"]["error"].nil?
        response
      else
        raise RateLimitExceeded, "You've 'literally' exceeded your API rate limit" if response["response"]["error"]["message"] == "You crossed your license limit"
      end
    end

    def raise_auth_exception(token)
      if token.nil?
        raise AuthenticationFailure.new("Good gracious! Incorrect credentials or too many active auth tokens")
      else
        token
      end
    end

  end
end
