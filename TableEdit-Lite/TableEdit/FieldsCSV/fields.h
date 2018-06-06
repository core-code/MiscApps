/*
 * Copyright (c) 2012 Jussi Virtanen
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpadded"


#ifndef FIELDS_H
#define FIELDS_H

#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/*
 * Fields
 * ======
 *
 * Fields is a fast C library for reading CSV and other tabular text formats.
 *
 *     https://github.com/jvirtanen/fields
 */

/*
 * Version
 * -------
 */

/*
 * The current version of the library.
 */
#define FIELDS_VERSION "0.6.0"

/*
 * Formats
 * -------
 */

/*
 * The input format.
 */
struct fields_format;

/*
 * Comma-separated values (CSV) use a comma (`,`) as the delimiter and a
 * double quote (`"`) for quoting.
 */
extern const struct fields_format fields_csv;

/*
 * Tab-separated values (TSV) use a tab (`\t`) as the delimiter and quoting
 * is disabled.
 */
extern const struct fields_format fields_tsv;

/*
 * Settings
 * --------
 */

/*
 * The settings for readers and records.
 */
struct fields_settings;

/*
 * The default settings.
 */
extern const struct fields_settings fields_defaults;

/*
 * Fields
 * ------
 */

/*
 * A field is a sequence of zero or more bytes.
 */
struct fields_field
{
    /*
     * The value. The value is a sequence of zero or more bytes and is followed
     * by a NUL character. The value may contain NUL characters.
     */
    const char *value;

    /*
     * The length of the value.
     */
    size_t length;
};

/*
 * Records
 * -------
 */

/*
 * A record is a sequence of zero or more fields.
 */
struct fields_record;

/*
 * Allocate a record. If `settings` is `NULL`, the default settings are used.
 *
 * - settings: the settings for the record
 *
 * If successful, returns a record object. Otherwise returns `NULL`.
 */
struct fields_record *fields_record_alloc(const struct fields_settings *);

/*
 * Deallocate the record.
 *
 * - record: the record object
 */
void fields_record_free(struct fields_record *);

/*
 * Get the field at the specified index. If successful, the operation updates
 * the field object. Otherwise the operation does not alter the field object.
 * The operation fails if the index is too large.
 *
 * - record: the record object
 * - index:  an index
 * - field:  a field object
 *
 * If successful, returns zero. Otherwise returns non-zero.
 */
int fields_record_field(const struct fields_record *, unsigned int,
    struct fields_field *);

/*
 * Get the number of fields in the record.
 *
 * - record: the record object
 *
 * Returns the number of fields in the record.
 */
size_t fields_record_size(const struct fields_record *);

/*
 * Positions
 * ---------
 */

/*
 * A position refers to a character in a text.
 */
struct fields_position
{
    /*
     * The character's row.
     */
    unsigned long row;

    /*
     * The character's column.
     */
    unsigned long column;
};

/*
 * Readers
 * -------
 */

/*
 * A reader reads records from a source, such as a buffer or a file.
 */
struct fields_reader;

/*
 * Allocate a reader that reads from the specified buffer. The operation fails
 * if the input format or the settings are erroneous. If `settings` is `NULL`,
 * the default settings are used.
 *
 * - buffer:      a buffer
 * - buffer_size: size of the buffer
 * - format:      the input format
 * - settings:    the settings for the reader
 *
 * If successful, returns a reader object. Otherwise returns `NULL`.
 */
struct fields_reader *fields_read_buffer(const char *, size_t,
    const struct fields_format *, const struct fields_settings *);

/*
 * Allocate a reader that reads from the specified file. The operation fails
 * if the input format or the settings are erroneous. If `settings` is `NULL`,
 * the default settings are used.
 *
 * - file:     a file
 * - format:   the input format
 * - settings: the settings for the reader
 *
 * If successful, returns a reader object. Otherwise returns `NULL`.
 */
struct fields_reader *fields_read_file(FILE *, const struct fields_format *,
    const struct fields_settings *);

/*
 * Deallocate the reader.
 *
 * - reader: the reader object
 */
void fields_reader_free(struct fields_reader *);

/*
 * Read a record. If successful, the operation updates the record object.
 * Otherwise the operation resets the record object. The operation fails at
 * end of input or upon error state.
 *
 * - reader: the reader object
 * - record: a record object
 *
 * If successful, returns zero. Otherwise returns non-zero.
 */
int fields_reader_read(struct fields_reader *, struct fields_record *);

/*
 * Get the current position of the reader. The operation updates the position
 * object.
 *
 * - reader:   the reader object
 * - position: a position object
 */
void fields_reader_position(const struct fields_reader *,
    struct fields_position *);

/*
 * Check whether the reader is in error state.
 *
 * - reader: the reader object
 *
 * Returns an error code if the reader is in error state. Otherwise returns zero.
 */
int fields_reader_error(const struct fields_reader *);

/*
 * Get a string representation of an error code.
 *
 * error: an error code
 *
 * Returns a string representation of the error code.
 */
const char *fields_reader_strerror(int);

/*
 * The error codes for a reader.
 */
enum fields_reader_error
{
    FIELDS_READER_ERROR_TOO_BIG_RECORD       = 1,
    FIELDS_READER_ERROR_TOO_MANY_FIELDS      = 2,
    FIELDS_READER_ERROR_UNEXPECTED_CHARACTER = 3,
    FIELDS_READER_ERROR_UNREADABLE_SOURCE    = 4
};

/*
 * Custom Formats
 * --------------
 */

struct fields_format
{
    /*
     * The delimiter character. Must not be `\n` or `\r`.
     */
    char delimiter;

    /*
     * The quote character. Must not be `\n`, `\r` or the delimiter character.
     * Set to `\0` to disable quoting.
     */
    char quote;
};

/*
 * Check whether the format is erroneous.
 *
 * - format: the format
 *
 * Returns an error code if the format is erroneous. Otherwise returns zero.
 */
int fields_format_error(const struct fields_format *);

/*
 * Get a string representation of an error code.
 *
 * - error: an error code
 *
 * Returns a string representation of the error code.
 */
const char *fields_format_strerror(int);

/*
 * The error codes for the format.
 */
enum fields_format_error
{
    FIELDS_FORMAT_ERROR_DELIMITER = 1,
    FIELDS_FORMAT_ERROR_QUOTE     = 2
};

/*
 * Custom Settings
 * ---------------
 */

struct fields_settings
{
    /*
     * Expand the record if needed. If true, whenever the limit for the record
     * buffer size or for the maximum number of fields in a record is reached,
     * the limit is doubled. If false or if the operation fails, the reader
     * enters the error state for too big record or too many fields.
     */
    int     expand;

    /*
     * Size of the buffer within a source.
     */
    size_t  source_buffer_size;

    /*
     * Size of the buffer within a record.
     */
    size_t  record_buffer_size;

    /*
     * The maximum number of fields a record may contain.
     */
    size_t  record_max_fields;
};

#define FIELDS_MINIMUM_SOURCE_BUFFER_SIZE (1024)
#define FIELDS_DEFAULT_SOURCE_BUFFER_SIZE (1024 * 1024)

#define FIELDS_MINIMUM_RECORD_BUFFER_SIZE (1024)
#define FIELDS_DEFAULT_RECORD_BUFFER_SIZE (1024 * 1024)

#define FIELDS_MINIMUM_RECORD_MAX_FIELDS (1)
#define FIELDS_DEFAULT_RECORD_MAX_FIELDS (1023)

/*
 * Check whether the settings are erroneous.
 *
 * - settings: the settings
 *
 * Returns an error code if the settings are erroneous. Otherwise returns
 * zero.
 */
int fields_settings_error(const struct fields_settings *);

/*
 * Get a string representation of an error code.
 *
 * - error: an error code
 *
 * Returns a string representation of the error code.
 */
const char *fields_settings_strerror(int);

/*
 * The error codes for settings.
 */
enum fields_settings_error
{
    FIELDS_SETTINGS_ERROR_SOURCE_BUFFER_SIZE = 1,
    FIELDS_SETTINGS_ERROR_RECORD_BUFFER_SIZE = 2,
    FIELDS_SETTINGS_ERROR_RECORD_MAX_FIELDS  = 3
};

/*
 * Custom Sources
 * --------------
 */

/*
 * Read from the source. If successful, the operation sets the pointer to a
 * buffer and the pointer to the size of the buffer. If the source is empty,
 * it sets the size of the buffer to zero.
 *
 * - source:      the source object
 * - buffer:      a pointer to a buffer
 * - buffer_size: a pointer to the size of the buffer
 *
 * If successful, returns zero. Otherwise returns non-zero.
 */
typedef int fields_source_read_fn(void *, const char **, size_t *);

/*
 * Deallocate the source.
 *
 * - source: the source object
 */
typedef void fields_source_free_fn(void *);

/*
 * Allocate a reader for the specified source. The operation fails if the
 * format or the settings are erroneous.
 *
 * - source:   the source object
 * - read:     the read method
 * - free:     the free method
 * - format:   the input format
 * - settings: the settings for the reader
 *
 * If successful, returns a reader object. Otherwise returns `NULL`.
 */
struct fields_reader *fields_reader_alloc(void *, fields_source_read_fn *,
    fields_source_free_fn *, const struct fields_format *,
    const struct fields_settings *);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* FIELDS_H */

#pragma clang diagnostic pop
