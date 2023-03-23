#!/bin/bash
kubectl apply -f database/manifests/
kubectl apply -f backend/manifests/
kubectl apply -f frontend/manifests/
