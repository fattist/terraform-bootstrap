variable "name" { type = string }

variable "capacity" {
    type = object({
        read = number
        write = number
    })
    default = {
        read = 5
        write = 5
    }
}

variable "hash" {
    type = object({
        name = string
    })
}

variable "stream" {
    type = object({
        enabled = bool
        view_type = string
    })
    default = {
        enabled = false
        view_type = ""
    }
}

variable "attr" {
    type = list(object({
        name = string
        type = string
    }))
    default = []
}

variable "gsi" {
    type = list(object({
        name = string
        hash_key = string
        write_capacity = number
        read_capacity = number
        projection_type = string
        non_key_attributes = list(string)
    }))
    default = []
}

resource "aws_dynamodb_table" "table" {
    name = var.name

    read_capacity = var.capacity.read
    write_capacity = var.capacity.write

    hash_key = var.hash.name

    stream_enabled = var.stream.enabled
    stream_view_type = var.stream.enabled ? var.stream.view_type : null

    dynamic "attribute" {
        for_each = var.attr
        content {
            name = attribute.value.name
            type = attribute.value.type
        }
    }

    dynamic "global_secondary_index" {
        for_each = var.gsi
        content {
            name = global_secondary_index.value.name
            hash_key = global_secondary_index.value.hash_key
            write_capacity = global_secondary_index.value.write_capacity
            read_capacity = global_secondary_index.value.read_capacity
            projection_type = global_secondary_index.value.projection_type
            non_key_attributes = global_secondary_index.value.projection_type != "ALL" ? global_secondary_index.value.non_key_attributes : null
        }
    }

    server_side_encryption {
        enabled = true
    }

    lifecycle {
        prevent_destroy = true
        ignore_changes = [
            read_capacity,
            write_capacity
        ]
    }
}

# EXPORTS

output "name" {
    value = aws_dynamodb_table.table.name
}

output "stream_arn" {
    value = aws_dynamodb_table.table.stream_arn
}