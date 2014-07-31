library model;

class Customer
{
  String _id;
  String get id => _id;
  String firstName;
  String lastName;
  String get name => "$firstName $lastName";
  
  Customer(this.firstName, this.lastName); 

  factory Customer.newCustomer(String id, Customer customer)
  {
    var newCustomer = new Customer(customer.firstName, customer.lastName);
    newCustomer._id = id;

    return newCustomer;
  }
}