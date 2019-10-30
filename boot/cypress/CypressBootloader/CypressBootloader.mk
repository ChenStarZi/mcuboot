################################################################################
# \file targets.mk
# \version 1.0
#
# \brief
# Makefile to describe supported boards and platforms for Cypress MCUBoot based applications.
#
################################################################################
# \copyright
# Copyright 2018-2019 Cypress Semiconductor Corporation
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

# Cypress' MCUBoot Application supports GCC ARM only at this moment 
# Set default compiler to GCC if not specified from command line
COMPILER ?= GCC_ARM

ifneq ($(COMPILER), GCC_ARM)
$(error Only GCC ARM is supported at this moment)
endif

CUR_APP_PATH = $(CURDIR)/$(APP_NAME)

include $(CUR_APP_PATH)/targets.mk
include $(CUR_APP_PATH)/libs.mk
include $(CUR_APP_PATH)/toolchains.mk

# add start address for each target device, since flash size is different
ifeq ($(TARGET), CY8CKIT-064S2-4343W-M0)
CY_BOOTLOADER_START ?= 0x101D0000 # PSoC6-2M
else
$(error $(APP_NAME) start address is not defined)
endif

# Application-specific DEFINES
DEFINES_APP := -DMBEDTLS_CONFIG_FILE="\"mcuboot_crypto_config.h\""
DEFINES_APP += -DECC256_KEY_FILE="\"keys/$(SIGN_KEY_FILE).pub\""
# use external flash map descriptors since flash map is driven by policy
DEFINES_APP += -DCY_FLASH_MAP_EXT_DESC
DEFINES_APP += -DCY_BOOTLOADER_START=$(CY_BOOTLOADER_START)
#DEFINES_APP += -DCY_BOOTLOADER_VERSION
#DEFINES_APP += -DCY_BOOTLOADER_BUILD

# TODO: MCUBoot library
# Collect MCUBoot sourses
SOURCES_MCUBOOT := $(wildcard $(CURDIR)/../bootutil/src/*.c)
# Collect MCUBoot Application sources
SOURCES_APP_SRC := $(wildcard $(CUR_APP_PATH)/source/*.c)
# Collect Flash Layer port sources
SOURCES_FLASH_PORT := $(wildcard $(CURDIR)/cy_flash_pal/*.c)
# Cy secureboot utils
SOURCES_SECBOOT_UTILS := $(wildcard $(CUR_APP_PATH)/cy_secureboot_utils/cy_jwt/*.c)
SOURCES_SECBOOT_UTILS += $(wildcard $(CUR_APP_PATH)/cy_secureboot_utils/cy_base64/base64/*.c)
SOURCES_SECBOOT_UTILS += $(wildcard $(CUR_APP_PATH)/cy_secureboot_utils/cy_cjson/cJSON/*.c)

# Collect all the sources
SOURCES_APP := $(SOURCES_MCUBOOT)
SOURCES_APP += $(SOURCES_APP_SRC)
SOURCES_APP += $(SOURCES_FLASH_PORT)
SOURCES_APP += $(SOURCES_SECBOOT_UTILS)

INCLUDES_DIRS_MCUBOOT := $(addprefix -I, $(CURDIR)/../bootutil/include)
INCLUDES_DIRS_MCUBOOT += $(addprefix -I, $(CURDIR)/../bootutil/src)

INCLUDE_DIRS_APP := $(addprefix -I, $(CURDIR))
INCLUDE_DIRS_APP += $(addprefix -I, $(CURDIR)/cy_flash_pal/include)
INCLUDE_DIRS_APP += $(addprefix -I, $(CURDIR)/cy_flash_pal/include/flash_map_backend)
INCLUDE_DIRS_APP += $(addprefix -I, $(CUR_APP_PATH))
INCLUDE_DIRS_APP += $(addprefix -I, $(CUR_APP_PATH)/config)
INCLUDE_DIRS_APP += $(addprefix -I, $(CUR_APP_PATH)/os)
INCLUDE_DIRS_APP += $(addprefix -I, $(CUR_APP_PATH)/cy_secureboot_utils/cy_jwt)
INCLUDE_DIRS_APP += $(addprefix -I, $(CUR_APP_PATH)/cy_secureboot_utils/cy_base64)
INCLUDE_DIRS_APP += $(addprefix -I, $(CUR_APP_PATH)/cy_secureboot_utils/cy_cjson/cJSON)

ASM_FILES_APP :=
