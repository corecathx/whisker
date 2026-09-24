import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.modules
import qs.components

ExpandableCard {
    title: "Preview"
    icon: "palette"
    ColumnLayout {
        spacing: 20

        RowLayout {
            spacing: 10
            anchors.left: parent.left
            anchors.right: parent.right

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width / 2
                ColorSchemePreviewCard { text: "Primary"; backgroundColor: Appearance.colors.m3primary; contentColor: Appearance.colors.m3on_primary }
                ColorSchemePreviewCard { text: "On Primary"; backgroundColor: Appearance.colors.m3on_primary; contentColor: Appearance.colors.m3primary }
                ColorSchemePreviewCard { text: "Primary Container"; backgroundColor: Appearance.colors.m3primary_container; contentColor: Appearance.colors.m3on_primary_container }
                ColorSchemePreviewCard { text: "On Primary Container"; backgroundColor: Appearance.colors.m3on_primary_container; contentColor: Appearance.colors.m3primary_container }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width / 2
                ColorSchemePreviewCard { text: "Secondary"; backgroundColor: Appearance.colors.m3secondary; contentColor: Appearance.colors.m3on_secondary }
                ColorSchemePreviewCard { text: "On Secondary"; backgroundColor: Appearance.colors.m3on_secondary; contentColor: Appearance.colors.m3secondary }
                ColorSchemePreviewCard { text: "Secondary Container"; backgroundColor: Appearance.colors.m3secondary_container; contentColor: Appearance.colors.m3on_secondary_container }
                ColorSchemePreviewCard { text: "On Secondary Container"; backgroundColor: Appearance.colors.m3on_secondary_container; contentColor: Appearance.colors.m3secondary_container }
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width / 2
                ColorSchemePreviewCard { text: "Tertiary"; backgroundColor: Appearance.colors.m3tertiary; contentColor: Appearance.colors.m3on_tertiary }
                ColorSchemePreviewCard { text: "On Tertiary"; backgroundColor: Appearance.colors.m3on_tertiary; contentColor: Appearance.colors.m3tertiary }
                ColorSchemePreviewCard { text: "Tertiary Container"; backgroundColor: Appearance.colors.m3tertiary_container; contentColor: Appearance.colors.m3on_tertiary_container }
                ColorSchemePreviewCard { text: "On Tertiary Container"; backgroundColor: Appearance.colors.m3on_tertiary_container; contentColor: Appearance.colors.m3tertiary_container }
            }
            Item {}
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width / 2
                ColorSchemePreviewCard { text: "Error"; backgroundColor: Appearance.colors.m3error; contentColor: Appearance.colors.m3on_error }
                ColorSchemePreviewCard { text: "On Error"; backgroundColor: Appearance.colors.m3on_error; contentColor: Appearance.colors.m3error }
                ColorSchemePreviewCard { text: "Error Container"; backgroundColor: Appearance.colors.m3error_container; contentColor: Appearance.colors.m3on_error_container }
                ColorSchemePreviewCard { text: "On Error Container"; backgroundColor: Appearance.colors.m3on_error_container; contentColor: Appearance.colors.m3error_container }
            }
        }

        RowLayout {
            spacing: 10
            anchors.left: parent.left
            anchors.right: parent.right

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width / 2
                ColorSchemePreviewCard { text: "Primary Fixed"; backgroundColor: Appearance.colors.m3primary_fixed; contentColor: Appearance.colors.m3on_primary_fixed }
                ColorSchemePreviewCard { text: "Primary Fixed Dim"; backgroundColor: Appearance.colors.m3primary_fixed_dim; contentColor: Appearance.colors.m3on_primary_fixed_dim }
                ColorSchemePreviewCard { text: "On Primary Fixed"; backgroundColor: Appearance.colors.m3on_primary_fixed; contentColor: Appearance.colors.m3primary_fixed }
                ColorSchemePreviewCard { text: "On Primary Fixed Variant"; backgroundColor: Appearance.colors.m3on_primary_fixed_variant; contentColor: Appearance.colors.m3primary_fixed_variant }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width / 2
                ColorSchemePreviewCard { text: "Secondary Fixed"; backgroundColor: Appearance.colors.m3secondary_fixed; contentColor: Appearance.colors.m3on_secondary_fixed }
                ColorSchemePreviewCard { text: "Secondary Fixed Dim"; backgroundColor: Appearance.colors.m3secondary_fixed_dim; contentColor: Appearance.colors.m3on_secondary_fixed_dim }
                ColorSchemePreviewCard { text: "On Secondary Fixed"; backgroundColor: Appearance.colors.m3on_secondary_fixed; contentColor: Appearance.colors.m3secondary_fixed }
                ColorSchemePreviewCard { text: "On Secondary Fixed Variant"; backgroundColor: Appearance.colors.m3on_secondary_fixed_variant; contentColor: Appearance.colors.m3secondary_fixed_variant }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width / 2
                ColorSchemePreviewCard { text: "Tertiary Fixed"; backgroundColor: Appearance.colors.m3tertiary_fixed; contentColor: Appearance.colors.m3on_tertiary_fixed }
                ColorSchemePreviewCard { text: "Tertiary Fixed Dim"; backgroundColor: Appearance.colors.m3tertiary_fixed_dim; contentColor: Appearance.colors.m3on_tertiary_fixed_dim }
                ColorSchemePreviewCard { text: "On Tertiary Fixed"; backgroundColor: Appearance.colors.m3on_tertiary_fixed; contentColor: Appearance.colors.m3tertiary_fixed }
                ColorSchemePreviewCard { text: "On Tertiary Fixed Variant"; backgroundColor: Appearance.colors.m3on_tertiary_fixed_variant; contentColor: Appearance.colors.m3tertiary_fixed_variant }
            }
            Item {}
            Item { Layout.fillWidth: true; Layout.preferredWidth: parent.width / 2}

        }

        RowLayout {
            spacing: 10
            anchors.left: parent.left
            anchors.right: parent.right

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width / 2
                ColorSchemePreviewCard { text: "Surface Dim"; backgroundColor: Appearance.colors.m3surface_dim; contentColor: Appearance.colors.m3on_surface }
                ColorSchemePreviewCard { text: "Surface"; backgroundColor: Appearance.colors.m3surface; contentColor: Appearance.colors.m3on_surface }
                ColorSchemePreviewCard { text: "Surface Bright"; backgroundColor: Appearance.colors.m3surface_bright; contentColor: Appearance.colors.m3on_surface }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width / 2
                ColorSchemePreviewCard { text: "Surface Container Lowest"; backgroundColor: Appearance.colors.m3surface_container_lowest; contentColor: Appearance.colors.m3on_surface }
                ColorSchemePreviewCard { text: "Surface Container Low"; backgroundColor: Appearance.colors.m3surface_container_low; contentColor: Appearance.colors.m3on_surface }
                ColorSchemePreviewCard { text: "Surface Container"; backgroundColor: Appearance.colors.m3surface_container; contentColor: Appearance.colors.m3on_surface }
                ColorSchemePreviewCard { text: "Surface Container High"; backgroundColor: Appearance.colors.m3surface_container_high; contentColor: Appearance.colors.m3on_surface }
                ColorSchemePreviewCard { text: "Surface Container Highest"; backgroundColor: Appearance.colors.m3surface_container_highest; contentColor: Appearance.colors.m3on_surface }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width / 2
                ColorSchemePreviewCard { text: "On Surface"; backgroundColor: Appearance.colors.m3on_surface; contentColor: Appearance.colors.m3surface }
                ColorSchemePreviewCard { text: "On Surface Variant"; backgroundColor: Appearance.colors.m3on_surface_variant; contentColor: Appearance.colors.m3surface_variant }
                ColorSchemePreviewCard { text: "Outline"; backgroundColor: Appearance.colors.m3outline; contentColor: Appearance.colors.m3on_surface }
                ColorSchemePreviewCard { text: "Outline Variant"; backgroundColor: Appearance.colors.m3outline_variant; contentColor: Appearance.colors.m3on_surface }
            }
            Item {}

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width / 2
                ColorSchemePreviewCard { text: "Inverse Surface"; backgroundColor: Appearance.colors.m3inverse_surface; contentColor: Appearance.colors.m3inverse_on_surface }
                ColorSchemePreviewCard { text: "Inverse On Surface"; backgroundColor: Appearance.colors.m3inverse_on_surface; contentColor: Appearance.colors.m3inverse_surface }
                ColorSchemePreviewCard { text: "Inverse Primary"; backgroundColor: Appearance.colors.m3inverse_primary; contentColor: Appearance.colors.m3on_inverse_primary }
                ColorSchemePreviewCard { text: "Scrim"; backgroundColor: Appearance.colors.m3scrim; contentColor: "white" }
                ColorSchemePreviewCard { text: "Shadow"; backgroundColor: Appearance.colors.m3shadow; contentColor: "white" }
            }
        }
    }
}
