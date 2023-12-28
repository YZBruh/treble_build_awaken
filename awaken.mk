$(call inherit-product, vendor/awaken/config/common_full_phone.mk)
$(call inherit-product, vendor/awaken/config/BoardConfigSoong.mk)
$(call inherit-product, device/awaken/sepolicy/common/sepolicy.mk)
-include vendor/awaken/build/core/config.mk

BOARD_EXT4_SHARE_DUP_BLOCKS := true

TARGET_BOOT_ANIMATION_RES := 1080

TARGET_SUPPORTS_QUICK_TAP := true

PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.system.ota.json_url=https://raw.githubusercontent.com/YZBruh/treble_build_awaken/udc/ota.json
