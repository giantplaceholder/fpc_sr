"""Native Darwin/AArch64 LLVM architecture and mixed-unit LTO regression.

Use an LLVM-enabled FPC and its matching RTL. The RTL may contain native
objects or LTO bitcode. Requires Apple clang and an LSE-capable machine.
"""
import argparse
import json
from pathlib import Path
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--compiler', type=Path, required=True)
    parser.add_argument('--rtl', type=Path, required=True)
    parser.add_argument('--work', type=Path, required=True)
    args = parser.parse_args()
    work = args.work.resolve()
    work.mkdir(parents=True, exist_ok=True)
    source = Path(__file__).resolve().parent
    sdk = subprocess.check_output(['xcrun', '--show-sdk-path'], text=True).strip()
    common = [str(args.compiler.resolve()), '-n', '-O2', '-Clv17.0',
              '-Aclang-llvm-darwin', '-a', '-Fu' + str(args.rtl.resolve()),
              '-XR' + sdk]

    def compile_step(directory, label, options):
        command = common + ['-FU' + str(directory), '-FE' + str(directory)] + options
        (directory / (label + '-command.json')).write_text(json.dumps(command, indent=2))
        result = subprocess.run(command, cwd=directory, text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        (directory / (label + '.log')).write_text(result.stdout)
        if result.returncode:
            raise RuntimeError(result.stdout)

    for lto in (False, True):
        directory = work / ('lto' if lto else 'native')
        directory.mkdir(exist_ok=True)
        options = ['-Clflto'] if lto else []
        # Darwin's default ARMv8.4-A includes LSE. The caller deliberately
        # uses ARMv8 so its declaration cannot supply the callee's features.
        compile_step(directory, 'unit', options + [str(source / 'ltoarchops.pas')])
        compile_step(directory, 'program', options + ['-CpARMV8',
                     '-Fu' + str(directory), str(source / 'ltoarch.pas')])
        unit_ir = (directory / 'ltoarchops.ll').read_text()
        program_ir = (directory / 'ltoarch.ll').read_text()
        definitions = [line for line in unit_ir.splitlines() if line.startswith('define ')]
        assert definitions and all('"target-features"="+v8.4a"' in line for line in definitions)
        definitions = [line for line in program_ir.splitlines() if line.startswith('define ')]
        assert definitions and all('"target-features"="+v8a"' in line for line in definitions)
        for ir in (unit_ir, program_ir):
            assert not any('"target-features"' in line for line in ir.splitlines()
                           if line.startswith('declare '))
        output = subprocess.check_output([str(directory / 'ltoarch')], text=True)
        assert output == 'OK\n', repr(output)
        print(directory.name + ': passed')


if __name__ == '__main__':
    main()
