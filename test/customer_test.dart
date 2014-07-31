import "package:unittest/unittest.dart";

import "dart:async";

import "package:contactManager/db.dart";
import "package:contactManager/model.dart";

void main() {
  group("Customer Model", () {
    test("Initialize", () {
      var customer = new Customer("Test", "User");
      expect(customer, isNotNull);
      expect(customer.firstName, "Test");
      expect(customer.lastName, "User");
    });

    test("Get Full Name", () {
      var customer = new Customer("Test", "User");
      expect(customer.name, "Test User");
    });
  });
  
  group("Repository", () {
    group("MemoryStrategy", () {
      test("Initialize", () {
        var memoryStrategy = new MemoryStrategy();
        var repository = new Repository(memoryStrategy);
        expect(repository, isNotNull);
      }); 
      
      test("Save Customer", () {
        var customer = new Customer("Test", "User");  
        var memoryStrategy = new MemoryStrategy();
        var repository = new Repository(memoryStrategy);
        
        return repository.saveCustomer(customer).then((savedCustomer) {
          expect(savedCustomer, isNotNull);  
          expect(savedCustomer.id, matches(r"[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}"));  
        })
        .catchError((error, stackTrace) {
          fail("Customer save error should not be thrown"); 
        }, test: (error) => error is! TestFailure);
      });
      
      group("Find Customer", () {
        test("By Customer ID", () {
          var memoryStrategy = new MemoryStrategy();
          var repository = new Repository(memoryStrategy);

          List<Customer> foundCustomers;
          return Future.wait([
            repository.saveCustomer(new Customer("Test", "User1")),
            repository.saveCustomer(new Customer("Test", "User2")),
            repository.saveCustomer(new Customer("Test", "User3")),
            repository.saveCustomer(new Customer("Test", "User4")),
            repository.saveCustomer(new Customer("Test", "User5"))
          ], eagerError: true).then((List<Customer> results) {
            foundCustomers = results;
            return repository.findCustomer(results[3].id);  
          }).then((customer) {
            expect(customer.id, isNotNull);
            expect(customer.id, foundCustomers[3].id);
          });
        });  

        test("All Customers", () {
          var memoryStrategy = new MemoryStrategy();
          var repository = new Repository(memoryStrategy);

          List<Customer> foundCustomers;
          return Future.wait([
            repository.saveCustomer(new Customer("Test", "User1")),
            repository.saveCustomer(new Customer("Test", "User2")),
            repository.saveCustomer(new Customer("Test", "User3")),
            repository.saveCustomer(new Customer("Test", "User4")),
            repository.saveCustomer(new Customer("Test", "User5"))
          ], eagerError: true).then((List<Customer> results) {
            foundCustomers = results;
            return repository.findCustomers();
          }).then((customers) {
            expect(customers, isNotNull);
            return customers.toList();
          }).then((customersAsList) {
            expect(customersAsList[2].id, foundCustomers[2].id);
          });
        });  

        test("Find Customer by Name", () {
          var memoryStrategy = new MemoryStrategy();
          var repository = new Repository(memoryStrategy);

          List<Customer> foundCustomers;
          return Future.wait([
            repository.saveCustomer(new Customer("Test", "User1")),
            repository.saveCustomer(new Customer("Test", "User2")),
            repository.saveCustomer(new Customer("Test", "User3")),
            repository.saveCustomer(new Customer("Test", "User4")),
            repository.saveCustomer(new Customer("Test", "User5"))
          ], eagerError: true).then((List<Customer> results) {
            foundCustomers = results;
            return repository.findCustomerByName("est user4");
          }).then((customer) {
            expect(customer, isNotNull);
            expect(customer.id, foundCustomers[3].id);
          });
        });  
      });
    });
  });
}

