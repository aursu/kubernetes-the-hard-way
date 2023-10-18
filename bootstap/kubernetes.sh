#!/bin/bash

bolt plan run puppet::agent::install targets=kubernetes

bolt plan run kubernetes::certificate::api
bolt plan run kubernetes::certificate::worker

bolt plan run kubernetes::config::api
bolt plan run kubernetes::config::worker

bolt plan run kubernetes::config::enc

bolt plan run kubernetes::bootstrap::etcd

bolt plan run kubernetes::bootstrap::control_plain
bolt plan run kubernetes::bootstrap::worker

bolt plan run kubernetes::bootstrap::components