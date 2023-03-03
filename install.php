<?php
/**
 * The following functions are used by the extension engine to generate a new table
 * for the plugin / destroy it on removal.
 */


/**
 * This function is called on installation and is used to
 * create database schema for the plugin
 */
function extension_install_greenit()
{
    $commonObject = new ExtensionCommon;

    $commonObject -> sqlQuery(
        "CREATE TABLE IF NOT EXISTS `greenit` (
        `ID` INTEGER NOT NULL AUTO_INCREMENT,
        `HARDWARE_ID` INTEGER NOT NULL,
        `DATETIME` DATETIME NOT NULL,
        `LIBRARY` VARCHAR(255) NOT NULL,
        `SENSOR` VARCHAR(255) NOT NULL,
        `VALUE` VARCHAR(255) NOT NULL,
        PRIMARY KEY (ID,HARDWARE_ID)) ENGINE=INNODB;"
    );
}

/**
 * This function is called on removal and is used to
 * destroy database schema for the plugin
 */
function extension_delete_greenit()
{
    $commonObject = new ExtensionCommon;
    $commonObject -> sqlQuery("DROP TABLE IF EXISTS `greenit`");
}

/**
 * This function is called on plugin upgrade
 */
function extension_upgrade_greenit()
{

}

?>