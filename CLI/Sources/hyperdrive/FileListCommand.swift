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
    let shortDescription = "Generate FileList file"

    let inputPath = Key<String>("--inputPath")
    let outputFile = Key<String>("--outputFile")

    public func execute() throws {
        guard let inputPath = inputPath.value, let inputPathURL = URL(string: "file://\(inputPath)") else {
            throw GenerateCommandError.inputPathInvalid
        }
        guard let outputFile = outputFile.value, let outputPathURL = URL(string: "file://\(outputFile)") else {
            throw GenerateCommandError.ouputFileInvalid
        }

        let inputFiles = FileManager.default.enumerator(at: inputPathURL, includingPropertiesForKeys: nil)?.compactMap { maybeUrl -> URL? in
            guard let url = maybeUrl as? URL else { return nil }
            return isInputFile(url: url) ? url : nil
        } ?? []

        let output = inputFiles.map {
            $0.path
        }.joined(separator: "\n")

        try output.write(to: outputPathURL, atomically: true, encoding: .utf8)

        print("File list generated successfully. \(inputFiles.count) input files.")
    }

    private func isInputFile(url: URL) -> Bool {
        return url.path.hasSuffix(".ui.xml") ||
            url.path.hasSuffix(".styles.xml") ||
            url.path.hasSuffix(".hyperdrive.xml")
    }
}
