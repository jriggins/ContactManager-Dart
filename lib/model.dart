library model;

class Contact
{
  String _id;

  String get id => _id;
  String firstName;
  String lastName;
  String get name => "$firstName $lastName";
  
  Contact(this.firstName, this.lastName); 

  Contact.withAllFields(String id, this.firstName, this.lastName) {
    _id = id;
  }

  factory Contact.newContact(String id, Contact customer)
  {
    var newContact = new Contact(customer.firstName, customer.lastName);
    newContact._id = id;

    return newContact;
  }
  
  Map<String, Object> toMap() {
    return {
      "id": id,
      "firstName": firstName,
      "lastName": lastName
    };
  }
}
