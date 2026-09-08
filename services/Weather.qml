pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// weather infos are provided by Open-Mateo
Singleton {
    id: weather

    property real latitude: 0
    property real longitude: 0
    property string location: ""

    property real temperature: 0
    property real apparentTemperature: 0
    property real humidity: 0
    property real windSpeed: 0

    property int weatherCode: 0
    property bool isDay: true

    property string condition: ""
    property string icon: ""

    property real airQuality: 0
    property real pm2_5: 0
    property real pm10: 0
    property real dust: 0

    property bool volcanicAsh: false
    property bool safeOutside: true
    property string safetyReason: ""

    property bool ready: false
    property bool loading: false

    function getCondition(code) {
        switch (code) {
        case 0:
            return "Clear sky"
        case 1:
            return "Mainly clear"
        case 2:
            return "Partly cloudy"
        case 3:
            return "Overcast"

        case 45:
        case 48:
            return "Foggy"

        case 51:
        case 53:
        case 55:
            return "Drizzle"

        case 56:
        case 57:
            return "Freezing drizzle"

        case 61:
        case 63:
        case 65:
            return "Rain"

        case 66:
        case 67:
            return "Freezing rain"

        case 71:
        case 73:
        case 75:
        case 77:
            return "Snow"

        case 80:
        case 81:
        case 82:
            return "Rain showers"

        case 85:
        case 86:
            return "Snow showers"

        case 95:
            return "Thunderstorm"

        case 96:
        case 99:
            return "Thunderstorm with hail"

        default:
            return "Unknown"
        }
    }

    function getIcon(code) {
        switch (code) {
        case 0:
            return isDay ? "sunny" : "clear_night"

        case 1:
        case 2:
            return isDay
                ? "partly_cloudy_day"
                : "partly_cloudy_night"

        case 3:
            return "cloud"

        case 45:
        case 48:
            return "foggy"

        case 51:
        case 53:
        case 55:
        case 56:
        case 57:
        case 61:
        case 63:
        case 65:
        case 66:
        case 67:
        case 80:
        case 81:
        case 82:
            return "rainy"

        case 71:
        case 73:
        case 75:
        case 77:
        case 85:
        case 86:
            return "weather_snowy"

        case 95:
        case 96:
        case 99:
            return "thunderstorm"

        default:
            return isDay ? "sunny" : "clear_night"
        }
    }

    function updateSafety() {
        safeOutside = true
        safetyReason = ""

        // figure out how to get this
        if (volcanicAsh) {
            safeOutside = false
            safetyReason = "Volcanic ash"
            return
        }

        if (weatherCode >= 95) {
            safeOutside = false
            safetyReason = "Thunderstorm"
            return
        }

        if (weatherCode === 66 || weatherCode === 67) {
            safeOutside = false
            safetyReason = "Freezing rain"
            return
        }

        if (airQuality >= 150) {
            safeOutside = false
            safetyReason = "Unhealthy air"
            return
        }

        if (apparentTemperature >= 40) {
            safeOutside = false
            safetyReason = "Extreme heat"
            return
        }
    }

    function update() {
        if (!latitude || !longitude)
            return

        loading = true

        weatherProcess.running = true
        airQualityProcess.running = true
    }

    /*
     * Location, from Public IP.
     */
    Process {
        id: locationProcess

        command: [
            "curl",
            "-fsSL",
            "-A",
            "Mozilla/5.0",
            "https://ipwho.is/"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(this.text)

                    if (!data.success) {
                        console.log(
                            "Weather location failed:",
                            data.message || "Unknown error"
                        )
                        return
                    }

                    weather.latitude = Number(data.latitude)
                    weather.longitude = Number(data.longitude)

                    if (data.city && data.region) {
                        weather.location = data.city + ", " + data.region
                    } else if (data.city) {
                        weather.location = data.city
                    } else {
                        weather.location = "Unknown"
                    }

                    console.log(
                        "Weather location:",
                        weather.location,
                        weather.latitude,
                        weather.longitude
                    )

                    weather.update()

                } catch (e) {
                    console.log("Weather location error:", e)
                    console.log("Response:", this.text)
                }
            }
        }
    }

    /*
     * Current weather.
     */
    Process {
        id: weatherProcess

        command: [
            "curl",
            "-fsSL",
            "https://api.open-meteo.com/v1/forecast" +
            "?latitude=" + weather.latitude +
            "&longitude=" + weather.longitude +
            "&current=" +
                "temperature_2m," +
                "relative_humidity_2m," +
                "apparent_temperature," +
                "weather_code," +
                "wind_speed_10m," +
                "is_day" +
            "&timezone=auto"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(this.text)
                    const current = data.current

                    if (!current)
                        return

                    weather.temperature = Number(current.temperature_2m)
                    weather.apparentTemperature = Number(current.apparent_temperature)

                    weather.humidity = Number(current.relative_humidity_2m)
                    weather.windSpeed = Number(current.wind_speed_10m)

                    weather.weatherCode = Number(current.weather_code)
                    weather.isDay = Number(current.is_day) === 1
                    weather.condition = weather.getCondition(weather.weatherCode)
                    weather.icon = weather.getIcon(weather.weatherCode)

                    weather.updateSafety()

                    weather.ready = true
                    weather.loading = false

                } catch (e) {
                    console.log("Weather error:", e)
                    console.log("Response:", this.text)

                    weather.loading = false
                }
            }
        }
    }

    /*
     * Air quality
     */
    Process {
        id: airQualityProcess

        command: [
            "curl",
            "-fsSL",
            "https://air-quality-api.open-meteo.com/v1/air-quality" +
            "?latitude=" + weather.latitude +
            "&longitude=" + weather.longitude +
            "&current=" +
                "us_aqi," +
                "pm2_5," +
                "pm10," +
                "dust" +
            "&timezone=auto"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(this.text)
                    const current = data.current

                    if (!current)
                        return

                    weather.airQuality = Number(current.us_aqi)
                    weather.pm2_5 = Number(current.pm2_5)
                    weather.pm10 = Number(current.pm10)
                    weather.dust = Number(current.dust)
                    weather.updateSafety()

                } catch (e) {
                    console.log("Air quality error:", e)
                    console.log("Response:", this.text)
                }
            }
        }
    }

    Timer {
        interval: 15 * 60 * 1000 // 15 mins
        running: weather.ready
        repeat: true

        onTriggered: weather.update()
    }
}