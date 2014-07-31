library db;

import "dart:async";

import "package:uuid/uuid_server.dart";

import "package:contactManager/model.dart";

abstract class DbStrategy {
  Future<Customer> saveCustomer(Customer customer);
  Future<Customer> findCustomer(String customerId);
  Stream<Customer> findCustomers();
  Future<Customer> findCustomerByName(String customerName);
}

class MemoryStrategy implements DbStrategy {

  List<Customer> customerList = [];
  
  @override
  Future<Customer> saveCustomer(Customer customer) {
    var newCustomerId = new Uuid().v4();
    var newCustomer = new Customer.newCustomer(newCustomerId, customer);
    customerList.add(newCustomer);
    return new Future.value(newCustomer);
  }
  
  @override
  Future<Customer> findCustomer(String customerId) {
    var foundCustomer = customerList.firstWhere((customer) => 
        customer.id == customerId);
    return new Future.value(foundCustomer);
  }

  @override
  Stream<Customer> findCustomers() {
    var stream = new Stream.fromIterable(customerList);
    return stream;
  }
  
  @override
  Future<Customer> findCustomerByName(String customerName) {
    var foundCustomer = customerList.firstWhere((customer) => 
        customer.name.toLowerCase().contains(customerName.toLowerCase()));
    return new Future.value(foundCustomer);
  }

}

class Repository {
  DbStrategy _dbStrategy;

  Repository(DbStrategy dbStrategy) {
    _dbStrategy = dbStrategy;
  }
  
  Future<Customer> saveCustomer(Customer customer) {
    return _dbStrategy.saveCustomer(customer);
  }
  
  Future<Customer> findCustomer(String customerId) {
    return _dbStrategy.findCustomer(customerId);   
  }
  
  Stream<Customer> findCustomers() {
    return _dbStrategy.findCustomers();
  }
  
  Future<Customer> findCustomerByName(String customerName) {
    return _dbStrategy.findCustomerByName(customerName);
  }
}