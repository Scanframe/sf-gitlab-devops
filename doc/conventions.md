@page conventions Conventions

# C++ Naming Conventions

This section contains design documentation.


## Definitions


### Types of 'Casings'

Names and examples of named case-types.  

#### Pascal Case (Studly Caps)
```
NumberOfWords = 3
MyGreetingText = "Hello World"
```

#### Camel Case
```
numberOfWords = 3
myGreetingText = "Hello World"
```

#### Upper Snake Case
```
NUMBER_OF_WORDS = 3
MY_GREETING_TEXT = "Hello World"
```

#### Lower Snake Case
```
number_of_words = 3
my_greeting_text = "Hello World"
```

#### Kebab cases
```
number-of-words = 3
my-greeting-text = "Hello World"
```

## Naming Convention

> This section is a far from complete but the basics are there at least.

### General 

* Types are always declared in a namespace (_to prevent naming collisions_).
* Each class has its own header and code file if possible.

### Files

#### Header files (.h)

Header files are clean and contain functions and class declarations having documentation blocks 
(Doxygen) and do not contain definitions to keep them clean and easy to read.  
A distinction is made between inline and non-inline definitions.

#### Definition files (.hpp)

Contains the definitions of template functions or class methods and inlined functions or 
class methods declared in the header file.

#### Definition files (.cpp)

Contain the definitions of the functions and class methods declared in the header files.

### Namespaces

* A namespace name is an abbreviation or mnemonic in all lowercase.

### Functions

* Names are in "Camel Case".
* The first word is verb in lowercase followed by one or more nouns.

### Classes & Structs

* The file is named after the class using "Pascal Case".
* The class name is a noun or a combination of nouns in "Pascal Case".
* Arguments passed to function are in "Lower Snake Case".
* Public data members are in "Camel Case".
* Private or protected data members are in "Camel Case" prefixed with an underscore '**_**'.
* Each method name begins with a verb followed by one or more nouns.
* Methods members are in "Camel Case".
* Method or constructor arguments are in "Lower Snake Case".

### Enumerates

* An enumerate type name is a noun or a combination of nouns in "Pascal Case" prefixed with '**E**'.
* Values entries of the enumerate are in "Camel Case" prefixed using all capitals of the type in lowercase.
* Anonymous enumerates are used as constants are named using "Upper Snake Case".

### Templates

* A template class name is a noun or a combination of nouns in "Pascal Case" prefixed with '**T**'.

### Defines or Global Constants

* Naming consists of nouns in "Upper Snake Case".
* Order the nouns in the name in order of importance.  

### Example

The example is using the Allman code styling of braces which translates 
to a [`.clang-format`]( ...clang-format/ ".clang-format project file") file.

Filename according this convention looks like this `ArgumentMultiplier.h` and has this fictive class.

```cpp
/**
 * @brief Just a defined maximum length.
 */
#define LENGTH_MAX 200

/**
 * @brief Another length but now as global constant.
 */
constexpr int LENGTH_MIN{100}; 

// Linux namespace.
namespace lnx
{

/**
 * @brief Class multiplying two arguments.
 */
class ArgumentMultiplier
{
  public:
    /**
     * @brief Constructor passing 2 arguments.
     * Arguments are in 'Lower Snake Case'.
     */
    ArgumentMultiplier(int argument_one, int argument_two);

    /**
     * @brief Gets the result of the multiplication.
     */
    [[nodiscard]] int getResult() const
    {
      return _argumentOne * _argumentTwo;
    };

    /**
     * @brief Result of the multiplication.
     * Enumerate types receive an 'E' prefix.
     */
    enum EResultType: int
    {
      /** Result of the multiplication is negative. */
      rtNegative = -1,
      /** Result of the multiplication is zero. */
      rtZero = 0,
      /** Result of the multiplication is positive. */
      rtPositive = 1,
    };

    /**
     * @brief Type of result after multiplication.
     */
    EResultType resultType{rtZero};
  
  private:
    /**
     * @brief Stored argument 1 passed in constructor.
     * A private or protected data member gets a underscore '_' prefix.
     */
    int _argumentOne{0};

    /**
     * @brief Stored argument 2 passed in constructor.
     */
    int _argumentTwo{0};
};

}
```


