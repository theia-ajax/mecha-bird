#!/bin/sh

SERVER_USER = ted
SERVER_ADDRESS = 173.255.220.111
TARGET_DIR = ../
TARGET = mecha-prototype.love

git archive --format zip --output $(TARGET_DIR)$(TARGET) master
scp $(TARGET_DIR)($TARGET) $(SERVER_USER)@$(SERVER_ADDRESS):~/$(TARGET)