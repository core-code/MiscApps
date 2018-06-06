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

#include <stdlib.h>
#include <unistd.h>

#include "fields.h"
#include "fields_posix.h"

#define FIELDS_FAILURE (-1)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpadded"
#pragma clang diagnostic ignored "-Wunreachable-code-return"
#pragma clang diagnostic ignored "-Wunused-command-line-argument"
#pragma clang diagnostic ignored "-Wcovered-switch-default"


struct fields_fd {
    int     fd;
    char *  buffer;
    size_t  buffer_size;
};

static struct fields_fd *
fields_fd_alloc(int fd, size_t buffer_size)
{
    struct fields_fd *self;
    char *buffer;

    buffer = malloc(buffer_size);
    if (buffer == NULL)
        return NULL;

    self = malloc(sizeof(*self));
    if (self == NULL) {
        free(buffer);
        return NULL;
    }

    self->fd = fd;
    self->buffer = buffer;
    self->buffer_size = buffer_size;

    return self;
}

static int
fields_fd_read(void *source, const char **buffer, size_t *buffer_size)
{
    struct fields_fd *self = source;
    ssize_t size;

    size = read(self->fd, self->buffer, self->buffer_size);
    if (size == -1)
        return FIELDS_FAILURE;

    *buffer = self->buffer;
    *buffer_size = size;

    return 0;
}

static void
fields_fd_free(void *source)
{
    struct fields_fd *self = source;

    free(self->buffer);
    free(self);
}

struct fields_reader *
fields_read_fd(int fd, const struct fields_format *format,
    const struct fields_settings *settings)
{
    struct fields_reader *reader;
    struct fields_fd *source;

    if (settings == NULL)
        settings = &fields_defaults;

    source = fields_fd_alloc(fd, settings->source_buffer_size);
    if (source == NULL)
        return NULL;

    reader = fields_reader_alloc(source, &fields_fd_read, &fields_fd_free,
        format, settings);
    if (reader == NULL) {
        fields_fd_free(source);
        return NULL;
    }

    return reader;
}

#pragma clang diagnostic pop
