# ZohoCrm

zoho_crm is a basic gem to interact with the Zoho API. Methods are only available for the Leads and Contacts Zoho modules. Communication is through instantiation of the main class **ZohoCRM::Client** which requires the user to have a Zoho username and password.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zoho_crm'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zoho_crm

## Usage

For first-time use, instantiate a client and generate an authentication token:

```ruby
client = ZohoCrm::Client.new("zoho@email.com", "myzohopassword")
auth_token = client.generate_auth_token
```

This has to be done only once, the first time you start using the API. You can save this token for later use.

Subsequently, when connecting to Zoho, you can just provide your stored authentication token:

```ruby
client = ZohoCrm::Client.new("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
```

You can interact with the Zoho API now.

The methods for the Contacts module are as follows:

```ruby
client.retrieve_contacts(from_index, to_index)
```

The maximum number of records returned in one request is 200. For example, to retrieve the fist 200 contacts the method would be:

```ruby
client.retrieve_contacts(1, 200)
```

Which returns a response in JSON format.

**data** is required to be supplied in the following format:

```ruby
data = {
          first_name: "Roger",
          last_name: "Jones",
          email: "roger@jones.com"
        }
```
**id** is the Zoho Contact ID which is part of the JSON response returned by the **retrieve_contacts** method.

```ruby
client.new_contact(data)
```

Up to 200 new Contacts can be added in batches using the **multiple_new_contacts** method.

```ruby
client.multiple_new_contacts(data)
```

Where **data** is an array of hashes

```ruby
data = [
          {email: "matt@craigs.com", first_name: "Matt", last_name: "Craigs"},
          {email: "roger@jones.com", first_name: "Roger", last_name: "Jones"}
       ]
```

```ruby
client.update_contact(data, id)
```

To update an individual Contact.

Only the fields being updated need to be supplied in **data**. The other fields will remain untouched.

Up to 100 Contacts can be updated in batches using the **update_multiple_contacts** method.

```ruby
client.update_multiple_contacts(data)
```

Where **data** is an array of hashes and the **ID** of the Contact must be given.
The **ID** is in the response from the **retrieve_contacts** method.

```ruby
data = [
          {id: "1234001", email: "matt@craigs.com", first_name: "Matt", last_name: "Craigs"},
          {id:"1234002", email: "roger@jones.com", first_name: "Roger", last_name: "Jones"}
       ]
```

```ruby
client.delete_contact(id)
```

Zoho requires **last_name** for Contacts. zoho_crm supported field names for the Contacts module are:

```ruby
data = {
          first_name: "Roger",
          last_name: "Jones",
          title: "CFO",
          department: "Leveraged Loans",
          phone: "1234",
          mobile: "1234",
          home_phone: "1234",
          other_phone: "1234",
          email: "roger@jones.com",
          mailing_street: "Welland Mews",
          mailing_city: "Welland Town",
          mailing_state: "Wellandville"
          mailing_zip: "ABC123"
          mailing_country: "Welland Republic"
          description: "a description"
        }
```

Limitations of these fields can be found at https://www.zoho.com/crm/help/api/modules-fields.html#Contacts

The methods for the Leads module are as follows:

```ruby
client.retrieve_leads(from_index, to_index)
```

The maximum number of records returned in one request is 200. For example, to retrieve the fist 200 leads the method would be:

```ruby
client.retrieve_leads("my_zoho_api_token", 1, 200)
```

Which returns a response in JSON format.

**data** is required to be supplied in the following format:

```ruby
data = {
          first_name: "Roger",
          last_name: "Jones",
          email: "roger@jones.com"
        }
```
**id** is the Zoho Lead ID which is part of the JSON response returned by the **retrieve_leads** method.

```ruby
client.new_lead(data)
```

Up to 200 new Leads can be added in batches using the **multiple_new_leads** method.

```ruby
client.multiple_new_leads(data)
```

Where **data** is an array of hashes

```ruby
data = [
          {email: "matt@craigs.com", first_name: "Matt", last_name: "Craigs", company: "Welland Capital"},
          {email: "roger@jones.com", first_name: "Roger", last_name: "Jones", company: "Welland Capital"}
       ]
```

```ruby
client.update_lead(data, id)
```

To update an individual Lead.

Only the fields being updated need to be supplied in **data**. The other fields will remain untouched.

Up to 100 Leads can be updated in batches using the **update_multiple_leads** method.

```ruby
client.update_multiple_leads(data)
```

Where **data** is an array of hashes and the **ID** of the Lead must be given.
The **ID** is in the response from the **retrieve_leads** method.

```ruby
data = [
          {id: "1234001", email: "matt@craigs.com", first_name: "Matt", last_name: "Craigs", company: "Welland Capital"},
          {id:"1234002", email: "roger@jones.com", first_name: "Roger", last_name: "Jones", company: "Welland Capital"}
       ]
```

```ruby
client.delete_lead(id)
```

Zoho requires **last_name** and **company** for Leads. The zoho_crm supported field names for the Leads module are:

```ruby
data = {
          first_name: "Roger",
          last_name: "Jones",
          title: "CFO",
          company: "Welland Capital",
          phone: "1234",
          mobile: "1234",
          email: "roger@jones.com",
          street: "Welland Mews",
          city: "Welland Town",
          state: "Wellandville"
          zip: "ABC123"
          country: "Welland Republic"
          description: "a description"
        }
```

Limitations of these fields can be found at https://www.zoho.com/crm/help/api/modules-fields.html#Leads

The fields for both the Contacts and Leads modules can be obtained with the following method:

```ruby
client.get_fields(module_name)
```

Which returns a response in JSON format.

Where **module_name** is either:

```ruby
"Contacts"
```

or

```ruby
"Leads"
```

If custom fields have been added to either the Contacts or Leads modules by a Zoho user then this will be indicated in the response from the **get_fields** method.

Provided a Zoho user has added custom fields, these can be populated using the **new_contact** , **new_lead** , **update_contact** and **update_lead** methods.

These can be added to **data** with the custom field name as a hash key in lower snake case. For example, if a Zoho user add custom fields **Gender** and **Football Team** then **data** would be:

```ruby
data = {
          gender: "Undisclosed",
          football_team: "Welland FC"
        }
```

N.B. It appears that zoho will only let 10 concurrent auth tokens be generated for each account. These auth tokens can be deleted manually in the 'My Account' section on Zoho.

## Contributing

1. Fork it ( https://github.com/cjlofts/zoho_crm/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
