use goolog::*;

set_caller!("Main");

fn main() {
    // It is necessary to call this function once. Otherwise some patches to the
    // runtime implemented by esp-idf-sys might not link properly. See https://github.com/esp-rs/esp-idf-template/issues/71
    esp_idf_svc::sys::link_patches();

    // Using a custom logger
    init_logger(None, None, None);

    // // Bind the log crate to the ESP Logging facilities
    // esp_idf_svc::log::EspLogger::initialize_default();

    info!("Hello, world!");
}
