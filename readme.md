# Library Database Management System

This project is aimed at creating a comprehensive database management system for a library. The system is designed to efficiently manage and organize various aspects of a library, including book information, author details, member data, and loan records. The system is built on a relational database using SQL to ensure data integrity and efficient data retrieval.

## Database Structure

The library database consists of several tables that store different types of information. Each table serves a specific purpose and is interconnected with other tables to maintain data consistency. Here's an overview of the key tables in the library database:

### GENRE Table

The `GENRE` table stores information about book genres. It includes the following columns:

- `genre_id`: A unique identifier for each genre.
- `name`: The name of the genre.
- `type`: A numeric field (0 for Fiction, 1 for Non-Fiction) to categorize the genre.
- Primary key: `genre_id`

### BOOK Table

The `BOOK` table contains information about books in the library. It includes the following columns:

- `title`: The title of the book (up to 100 characters).
- `genre_id`: A reference to the genre of the book.
- `ISBN`: The International Standard Book Number.
- `date_published`: The publication date of the book.
- `publisher`: The name of the publisher.
- `edition`: The edition number of the book.
- `description`: A concise description of the book (up to 300 characters).
- Primary key: `ISBN`
- Foreign key: `genre_id` references `GENRE(genre_id)`

### AUTHOR Table

The `AUTHOR` table stores information about the authors of the books. It includes the following columns:

- `author_id`: A unique identifier for each author.
- `first_name`: The first name of the author.
- `middle_name`: The middle name of the author.
- `last_name`: The last name of the author (required).
- Primary key: `author_id`

### BOOK_AUTHOR Table

The `BOOK_AUTHOR` table establishes a relationship between books and authors. It includes the following columns:

- `ISBN`: The International Standard Book Number.
- `author_id`: A reference to the author of the book.
- Primary key: `(author_id, ISBN)`
- Foreign keys: `author_id` references `AUTHOR(author_id)` and `ISBN` references `BOOK(ISBN)`

### COPY Table

The `COPY` table stores information about physical copies of books in the library. It includes the following columns:

- `barcode`: A unique identifier for each copy.
- `ISBN`: A reference to the book the copy is associated with.
- `comment`: A comment regarding the physical quality of the copy (nullable).
- Primary key: `barcode`
- Foreign key: `ISBN` references `BOOK(ISBN)`

### MEMBER Table

The `MEMBER` table stores information about library members. It includes the following columns:

- `card_no`: A unique card number for each member.
- `first_name`: The first name of the member.
- `middle_name`: The middle name of the member.
- `last_name`: The last name of the member (required).
- `street`: The street name of the member's address.
- `city`: The city of the member's address.
- `state`: The U.S. state where the member resides (using a predefined list of states).
- `apt_no`: The apartment number (nullable).
- `zip_code`: The ZIP code of the member's address.
- `phone_no`: The member's phone number (required).
- `email_address`: The member's email address (nullable).
- `card_exp_date`: The expiration date of the member's library card.
- Primary key: `card_no`

### BORROW Table

The `BORROW` table tracks information about book loans. It includes the following columns:

- `card_no`: The card number of the member borrowing the book.
- `barcode`: The barcode of the book copy being borrowed.
- `date_borrowed`: The date when the book was borrowed.
- `date_returned`: The date when the book was returned.
- `renewals_no`: The number of renewals allowed (non-negative, default is 0).
- `paid`: A boolean field indicating whether the member has paid for the loan.
- Primary key: `(card_no, barcode, date_borrowed)`
- Foreign keys: `barcode` references `COPY(barcode)` and `card_no` references `MEMBER(card_no)`

## Getting Started

To use this database management system, you can follow these steps:

1. Create a database named `library`.
2. Run the provided SQL script to create the necessary tables.
3. You can then interact with the database using SQL queries to manage book records, author details, member information, and loan records.

Please refer to the SQL script in this repository for detailed table creation and field definitions.

For any issues or questions, please feel free to reach out.

Happy library management!