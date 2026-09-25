"""Regression checks for silent LibreOffice failures and repeated basenames."""

import importlib.util
import tempfile
import types
import unittest
from pathlib import Path
from unittest.mock import patch

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/16_build_document_previews.py"
spec = importlib.util.spec_from_file_location("document_previews", SCRIPT)
previews = importlib.util.module_from_spec(spec)
spec.loader.exec_module(previews)


class DocumentPreviewTests(unittest.TestCase):
    def test_missing_pdf_cannot_reuse_previous_source_with_same_name(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            sources = [
                root / "data" / poll / "questionnaire.doc" for poll in ("a", "b")
            ]
            for source in sources:
                source.parent.mkdir(parents=True)
                source.write_text(source.parent.name)
            outputs = []

            def convert(command, **kwargs):
                output = Path(command[command.index("--outdir") + 1])
                outputs.append(output)
                if len(outputs) == 1:
                    (output / "questionnaire.pdf").write_bytes(b"first document PDF")
                return types.SimpleNamespace(returncode=0)

            def inspect(command, **kwargs):
                return {
                    "soffice": "LibreOffice test",
                    "pdfinfo": "Pages: 1\n",
                    "pdftotext": "first document text",
                }[command[0]]

            with (
                patch.object(previews, "__file__", str(root / "scripts/previews.py")),
                patch("sys.argv", ["previews", "--report", str(root / "report.json")]),
                patch.object(
                    previews.shutil, "which", side_effect=lambda command: command
                ),
                patch.object(previews.subprocess, "run", side_effect=convert),
                patch.object(previews.subprocess, "check_output", side_effect=inspect),
                patch.object(previews.platform, "platform", return_value="test"),
                self.assertRaisesRegex(SystemExit, "no PDF conversion: data/b/"),
            ):
                previews.main()
            self.assertEqual(len(outputs), 2)
            self.assertNotEqual(outputs[0].parent, outputs[1].parent)
            self.assertEqual(
                sources[0].with_suffix(".pdf").read_bytes(), b"first document PDF"
            )
            self.assertFalse(sources[1].with_suffix(".pdf").exists())
            self.assertEqual([source.read_text() for source in sources], ["a", "b"])

    def test_missing_xlsx_is_rejected_before_loading_any_workbook(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            previous = root / "previous/workbook/questionnaire.xlsx"
            previous.parent.mkdir(parents=True)
            previous.write_bytes(b"previous unrelated workbook")
            current = root / "current"
            current.mkdir()
            source = root / "questionnaire.xls"
            source.write_bytes(b"new original workbook")
            with (
                patch.dict("sys.modules", {"openpyxl": types.SimpleNamespace()}),
                patch.object(
                    previews.subprocess,
                    "run",
                    return_value=types.SimpleNamespace(returncode=0),
                ),
                self.assertRaisesRegex(SystemExit, "no XLSX conversion"),
            ):
                previews.prepare_workbook(source, current, ["soffice"])
            self.assertEqual(previous.read_bytes(), b"previous unrelated workbook")
            self.assertEqual(source.read_bytes(), b"new original workbook")


if __name__ == "__main__":
    unittest.main()
