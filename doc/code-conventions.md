# C++ Naming Conventions {#code-conventions}

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

> This section is far from complete, but the basics are there at least.

### General

* Types are always declared in a namespace (_to prevent naming collisions_).
* Each class has its own header and code file if possible.

### Files

#### Header files (.h)

Header files are clean and contain functions and class declarations having documentation blocks (Doxygen) and do not
contain definitions to keep them clean and easy to read.  
A distinction is made between inline and non-inline definitions.

#### Definition files (.hpp)

Contains the definitions of template functions or class methods and inlined functions or class methods declared in the
header file.

#### Definition files (.cpp)

Contain the definitions of the functions and class methods declared in the header files.

### Namespaces

* A namespace name is an abbreviation or mnemonic in all lowercase.

### Functions

* Names are in "Camel Case".
* The first word is a verb in the lowercase followed by one or more nouns.

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
* Values entries of an enumeration are in "Camel Case" prefixed using all capitals of the type in lowercase.
* Anonymous enumerates are used as constants are named using "Upper Snake Case".

### Templates

* A template class name is a noun or a combination of nouns in "Pascal Case" prefixed with '**T**'.

### Defines or Global Constants

* Naming consists of nouns in 'Upper-Snake-Case'.
* Order the nouns in the name in order of importance.

### Example

The example is using the Allman code styling of braces which translates to a
[`.clang-format`](../.clang-format/ ".clang-format project file.") file.

Filename, according to this convention, looks like this `ArgumentMultiplier.h` and has this fictive class.

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

## AI Rules as Context for Generating Code

The following should be copied when asking for code C++ generation by an AI to get the correct formatted code.

```text
Apply the following instructions on generating the C++ code:

- Use only up to C++17.
- Enforcing Allman bracing.
- Doxygen-style comments in headers only.
- Use `#pragma once` as header sentries.
- Use tabs for indentation.
- Use tabs size is 2 characters.
- Use no open lines in function bodies.
- Comments in code are always placed above the code line and never behind it.
- Comments must be full sentences ending with a period.
- Comments must be placed above the code line they describe, never trailing on the same line.
- Camel-case naming is used for object methods.
- Camel-case naming is used for object data-members and starts with an underscore.
- Lower-snake-case is used for class method and function argument names and also for the variables declared in them.
- Const expression and define names are in Upper-Case-Snake.
- Pascal Case is used for naming classes and structures.
- Pascal Case is used for naming enumerate types and prefixed with the letter 'E'.
```
