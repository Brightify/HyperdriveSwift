//
//  FileListCommand.swift
//  hyperdrive-cli
//
//  Created by Tadeas Kriz on 12/12/2019.
//

import Foundation
import SwiftCLI

final class FilelistCommand: Command {
    let name = "filelist"
    let shortDescription = "Generate FileList files"

    let inputPath = Key<String>("--inputPath", description: "Path where Hyperdrive input files are located.")
    let outputFile = Key<String>("--outputFile", description: "File to which interface is generated when running in single-file mode.")
    let outputPath = Key<String>("--outputPath", description: "Directory to which interface is generated when running in multi-file mode.")
    let inputFilelist = Flag("--inputFilelist", description: "Enables input filelist generation")
    let outputFilelist = Flag("--outputFilelist", description: "Enables output filelist generation")
    let inputFilelistPath = Key<String>("--inputFilelistPath", description: "Path where input filelist will be written.")
    let outputFilelistPath = Key<String>("--outputFilelistPath", description: "Path where output filelist will be written.")

    public func execute() throws {
        guard let inputPath = inputPath.value, let inputPathURL = URL(string: "file://\(inputPath)") else {
            throw GenerateCommandError.inputPathInvalid
        }

        let inputFiles = FileManager.default.enumerator(at: inputPathURL, includingPropertiesForKeys: nil)?.compactMap { maybeUrl -> URL? in
            guard let url = maybeUrl as? URL else { return nil }
            return isInputFile(url: url) ? url : nil
        } ?? []

        let inputFilePaths = inputFiles.map { $0.path }.joined(separator: "\n")

        let outputFiles: [URL]
        if let outputPath = outputPath.value {
            guard let outputPathURL = URL(string: "file://\(outputPath)") else {
                throw GenerateCommandError.ouputFileInvalid
            }

            outputFiles = inputFiles.map {
                outputPathURL.appendingPathComponent($0.deletingPathExtension().lastPathComponent).appendingPathExtension(".generated.swift")
            }
        } else if let outputFile = outputFile.value {
            guard let outputFileURL = URL(string: "file://\(outputFile)") else {
                throw GenerateCommandError.ouputFileInvalid
            }

            outputFiles = [outputFileURL]
        } else {
            outputFiles = []
        }
        let outputFilePaths = outputFiles.map { $0.path }.joined(separator: "\n")

        var standardOutput: Bool = false
        if inputFilelist.value {
            if let inputFilelistPath = inputFilelistPath.value {
                try inputFilePaths.write(to: URL(fileURLWithPath: inputFilelistPath), atomically: true, encoding: .utf8)
            } else {
                print(inputFilePaths)
                standardOutput = true
            }
        }

        if outputFilelist.value {
            if let outputFilelistPath = outputFilelistPath.value {
                try outputFilePaths.write(to: URL(fileURLWithPath: outputFilelistPath), atomically: true, encoding: .utf8)
            } else {
                print(outputFilePaths)
                standardOutput = true
            }
        }

        // We don't want to print this if we're printing the filelist to console so that the list can be piped to other commands
        if !standardOutput {
            print("File list generated successfully. \(inputFiles.count) input files.")
        }
    }

    private func isInputFile(url: URL) -> Bool {
        return url.path.hasSuffix(".ui.xml") ||
            url.path.hasSuffix(".styles.xml") ||
            url.path.hasSuffix(".hyperdrive.xml")
    }
}
