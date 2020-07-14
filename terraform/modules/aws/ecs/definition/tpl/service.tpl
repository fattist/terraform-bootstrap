[
  {
    "cpu": ${cpu},
    "image": "${image}",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${environment}/${service}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "memory": ${memory},
    "name": "${service}",
    "networkMode": "${networkMode}",
    "portMappings": [
      {
        "containerPort": ${containerPort},
        "hostPort": ${hostPort}
      }
    ]
  }
]