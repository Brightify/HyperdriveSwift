import Generator
import Tokenizer
import xcodeproj
import SwiftCLI

let generateCommand = GenerateCommand()
let xsdCommand = XSDCommand()

let cli = CLI(
    name: "hyperdrive",
    version: "2.0.0-alpha.1",
    description: """
        Command line tool for the Hyperdrive platform, used to generate UI from XML files and initialize new projects.
    """,
    commands: [generateCommand, xsdCommand])

cli.goAndExit()
