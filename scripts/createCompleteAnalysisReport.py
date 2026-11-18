from __future__ import annotations

import csv
import math
import os
from pathlib import Path

from docx import Document
from docx.enum.section import WD_ORIENT, WD_SECTION
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT, WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_BREAK, WD_LINE_SPACING
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Inches, Pt, RGBColor


ROOT = Path(__file__).resolve().parent.parent
RESULTS = ROOT / "results" / "outbreak_origin_scenarios"
OUTPUT = ROOT / "output"
REPORT_DIR = OUTPUT / "documents"
REPORT_PATH = REPORT_DIR / "Surviving_the_Outbreak_at_FEU_Tech_Complete_Model_Analysis.docx"

NAVY = "17365D"
BLUE = "2F75B5"
PALE_BLUE = "DDEBF7"
PALE_GRAY = "F2F2F2"
GRID = "D9D9D9"
BLACK = RGBColor(0, 0, 0)
MUTED = RGBColor(89, 89, 89)


def set_cell_shading(cell, fill: str) -> None:
    tc_pr = cell._tc.get_or_add_tcPr()
    shd = tc_pr.find(qn("w:shd"))
    if shd is None:
        shd = OxmlElement("w:shd")
        tc_pr.append(shd)
    shd.set(qn("w:fill"), fill)


def set_cell_margins(cell, top=90, start=100, bottom=90, end=100) -> None:
    tc = cell._tc
    tc_pr = tc.get_or_add_tcPr()
    tc_mar = tc_pr.first_child_found_in("w:tcMar")
    if tc_mar is None:
        tc_mar = OxmlElement("w:tcMar")
        tc_pr.append(tc_mar)
    for tag, value in (("top", top), ("start", start), ("bottom", bottom), ("end", end)):
        node = tc_mar.find(qn(f"w:{tag}"))
        if node is None:
            node = OxmlElement(f"w:{tag}")
            tc_mar.append(node)
        node.set(qn("w:w"), str(value))
        node.set(qn("w:type"), "dxa")


def set_table_borders(table, color=GRID, size="6") -> None:
    tbl_pr = table._tbl.tblPr
    borders = tbl_pr.first_child_found_in("w:tblBorders")
    if borders is None:
        borders = OxmlElement("w:tblBorders")
        tbl_pr.append(borders)
    for edge in ("top", "left", "bottom", "right", "insideH", "insideV"):
        el = borders.find(qn(f"w:{edge}"))
        if el is None:
            el = OxmlElement(f"w:{edge}")
            borders.append(el)
        el.set(qn("w:val"), "single")
        el.set(qn("w:sz"), size)
        el.set(qn("w:color"), color)


def set_repeat_table_header(row) -> None:
    tr_pr = row._tr.get_or_add_trPr()
    tbl_header = OxmlElement("w:tblHeader")
    tbl_header.set(qn("w:val"), "true")
    tr_pr.append(tbl_header)


def set_font(run, name="Arial", size=None, bold=None, color=BLACK, italic=None) -> None:
    run.font.name = name
    run._element.get_or_add_rPr().rFonts.set(qn("w:ascii"), name)
    run._element.get_or_add_rPr().rFonts.set(qn("w:hAnsi"), name)
    if size is not None:
        run.font.size = Pt(size)
    if bold is not None:
        run.bold = bold
    if italic is not None:
        run.italic = italic
    if color is not None:
        run.font.color.rgb = color


def configure_styles(doc: Document) -> None:
    styles = doc.styles
    normal = styles["Normal"]
    normal.font.name = "Arial"
    normal._element.rPr.rFonts.set(qn("w:ascii"), "Arial")
    normal._element.rPr.rFonts.set(qn("w:hAnsi"), "Arial")
    normal.font.size = Pt(11)
    normal.font.color.rgb = BLACK
    normal.paragraph_format.space_after = Pt(7)
    normal.paragraph_format.line_spacing = 1.12

    title = styles["Title"]
    title.font.name = "Arial"
    title._element.rPr.rFonts.set(qn("w:ascii"), "Arial")
    title._element.rPr.rFonts.set(qn("w:hAnsi"), "Arial")
    title.font.size = Pt(28)
    title.font.bold = True
    title.font.color.rgb = BLACK
    title.paragraph_format.space_after = Pt(14)
    title_ppr = title.element.get_or_add_pPr()
    title_border = title_ppr.find(qn("w:pBdr"))
    if title_border is not None:
        title_ppr.remove(title_border)

    for style_name, size, before, after in (
        ("Heading 1", 18, 18, 8),
        ("Heading 2", 14, 14, 6),
        ("Heading 3", 11.5, 10, 4),
    ):
        st = styles[style_name]
        st.font.name = "Arial"
        st._element.rPr.rFonts.set(qn("w:ascii"), "Arial")
        st._element.rPr.rFonts.set(qn("w:hAnsi"), "Arial")
        st.font.size = Pt(size)
        st.font.bold = True
        st.font.color.rgb = BLACK
        st.paragraph_format.space_before = Pt(before)
        st.paragraph_format.space_after = Pt(after)
        st.paragraph_format.keep_with_next = True

    caption = styles["Caption"]
    caption.font.name = "Arial"
    caption._element.rPr.rFonts.set(qn("w:ascii"), "Arial")
    caption._element.rPr.rFonts.set(qn("w:hAnsi"), "Arial")
    caption.font.size = Pt(9)
    caption.font.italic = True
    caption.font.color.rgb = MUTED
    caption.paragraph_format.space_before = Pt(4)
    caption.paragraph_format.space_after = Pt(9)
    caption.paragraph_format.keep_with_next = True


def configure_section(section, landscape=False) -> None:
    if landscape:
        section.orientation = WD_ORIENT.LANDSCAPE
        section.page_width = Inches(11)
        section.page_height = Inches(8.5)
        section.top_margin = Inches(0.55)
        section.bottom_margin = Inches(0.55)
        section.left_margin = Inches(0.65)
        section.right_margin = Inches(0.65)
    else:
        section.orientation = WD_ORIENT.PORTRAIT
        section.page_width = Inches(8.5)
        section.page_height = Inches(11)
        section.top_margin = Inches(0.72)
        section.bottom_margin = Inches(0.72)
        section.left_margin = Inches(0.82)
        section.right_margin = Inches(0.82)
    section.header_distance = Inches(0.3)
    section.footer_distance = Inches(0.35)


def add_page_number(section) -> None:
    p = section.footer.paragraphs[0]
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(0)
    p.paragraph_format.space_after = Pt(0)
    run = p.add_run()
    fld_char1 = OxmlElement("w:fldChar")
    fld_char1.set(qn("w:fldCharType"), "begin")
    instr = OxmlElement("w:instrText")
    instr.set(qn("xml:space"), "preserve")
    instr.text = " PAGE "
    fld_char2 = OxmlElement("w:fldChar")
    fld_char2.set(qn("w:fldCharType"), "end")
    run._r.append(fld_char1)
    run._r.append(instr)
    run._r.append(fld_char2)
    set_font(run, size=9, color=MUTED)


def add_title(doc: Document) -> None:
    p = doc.add_paragraph(style="Title")
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    p.paragraph_format.space_before = Pt(54)
    p.add_run("Surviving the Outbreak at FEU Tech")

    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(30)
    r = p.add_run("Complete Agent Based Simulation Analysis")
    set_font(r, name="Arial", size=17, bold=False, color=MUTED)

    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(6)
    r = p.add_run("Model scope")
    set_font(r, size=10, bold=True)
    p = doc.add_paragraph("Fifteen modeled physical levels  |  3,713 agents in the primary run  |  24 simulated hours  |  Three outbreak origins")
    p.paragraph_format.space_after = Pt(18)

    p = doc.add_paragraph()
    r = p.add_run("Core conclusion")
    set_font(r, size=10, bold=True)
    p = doc.add_paragraph(
        "Under the current assumptions, the sixteenth floor origin produces the most severe and most consistently high infection burden. "
        "The eighth floor origin is also severe but more variable, while the second floor origin produces the lowest infection burden because it begins near an authorized exit and below most occupants."
    )
    p.paragraph_format.space_after = Pt(30)

    p = doc.add_paragraph("Modeling and Simulation Final Project")
    p.paragraph_format.space_after = Pt(4)
    p = doc.add_paragraph("November 2026")
    p.add_run().add_break(WD_BREAK.PAGE)


def add_heading(doc, text, level=1):
    return doc.add_heading(text, level=level)


def add_paragraph(doc, text, bold_lead=None):
    p = doc.add_paragraph()
    if bold_lead and text.startswith(bold_lead):
        r = p.add_run(bold_lead)
        set_font(r, bold=True)
        r = p.add_run(text[len(bold_lead):])
        set_font(r)
    else:
        r = p.add_run(text)
        set_font(r)
    return p


def add_bullets(doc, items):
    for item in items:
        p = doc.add_paragraph()
        p.paragraph_format.space_after = Pt(3)
        p.paragraph_format.left_indent = Inches(0.28)
        p.paragraph_format.first_line_indent = Inches(-0.2)
        bullet = p.add_run("•  ")
        set_font(bullet)
        r = p.add_run(item)
        set_font(r)


def add_table(doc, headers, rows, widths=None, font_size=9, numeric_cols=None):
    numeric_cols = set(numeric_cols or [])
    table = doc.add_table(rows=1, cols=len(headers))
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False
    set_table_borders(table)
    set_repeat_table_header(table.rows[0])
    for j, header in enumerate(headers):
        cell = table.rows[0].cells[j]
        set_cell_shading(cell, NAVY)
        set_cell_margins(cell)
        cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_after = Pt(0)
        r = p.add_run(str(header))
        set_font(r, size=font_size, bold=True, color=RGBColor(255, 255, 255))
        if widths:
            cell.width = Inches(widths[j])
    for i, row in enumerate(rows):
        cells = table.add_row().cells
        for j, value in enumerate(row):
            cell = cells[j]
            set_cell_margins(cell)
            cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
            if i % 2:
                set_cell_shading(cell, PALE_BLUE)
            p = cell.paragraphs[0]
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER if j in numeric_cols else WD_ALIGN_PARAGRAPH.LEFT
            p.paragraph_format.space_after = Pt(0)
            r = p.add_run(str(value))
            set_font(r, size=font_size)
            if widths:
                cell.width = Inches(widths[j])
    doc.add_paragraph().paragraph_format.space_after = Pt(1)
    return table


def add_figure(doc, image_path: Path, caption: str, width: float, analysis: str | None = None) -> None:
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.keep_with_next = True
    p.paragraph_format.space_after = Pt(0)
    shape = p.add_run().add_picture(str(image_path), width=Inches(width))
    shape._inline.docPr.set("descr", caption)
    shape._inline.docPr.set("title", caption.split(".", 1)[0])
    cp = doc.add_paragraph(caption, style="Caption")
    cp.alignment = WD_ALIGN_PARAGRAPH.CENTER
    if analysis:
        p = add_paragraph(doc, analysis)
        p.paragraph_format.space_after = Pt(0)


def add_landscape_page(doc, heading: str, image: Path, caption: str, analysis: str, width=9.3, first=False):
    if not first:
        doc.add_page_break()
    h = add_heading(doc, heading, 2)
    h.paragraph_format.space_before = Pt(0)
    add_figure(doc, image, caption, width, analysis)


def read_csv(path: Path):
    with path.open(newline="", encoding="utf-8-sig") as f:
        return list(csv.DictReader(f))


def main() -> None:
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    doc = Document()
    configure_styles(doc)
    configure_section(doc.sections[0], landscape=False)
    add_page_number(doc.sections[0])
    doc.core_properties.title = "Surviving the Outbreak at FEU Tech Complete Agent Based Simulation Analysis"
    doc.core_properties.subject = "Analysis of outbreak origin scenarios, graphs, heat maps, and simulation statistics"
    doc.core_properties.author = "Modeling and Simulation Project Team"
    doc.core_properties.keywords = "agent based model, FEU Tech, outbreak simulation, heat map, evacuation"

    add_title(doc)

    add_heading(doc, "Executive Summary", 1)
    add_paragraph(
        doc,
        "This report evaluates an agent based outbreak model of FEU Tech across three controlled scenarios that differ only in the initial infected location: the second floor Student Plaza, the eighth floor Canteen, and a randomly selected sixteenth floor office. The primary run contains 3,713 agents and advances in 10 minute increments for 24 simulated hours. Agents end in one of three reporting categories: Infected, Non Infected, or Escaped."
    )
    add_paragraph(
        doc,
        "The results show a strong origin effect. In the primary seed, final infection reaches 20.85 percent for the second floor origin, 77.59 percent for the eighth floor origin, and 86.29 percent for the sixteenth floor origin. The three seed comparison preserves the same ordering: mean infection rates are 22.68 percent, 72.39 percent, and 86.25 percent, respectively. The sixteenth floor result is both the highest and the most stable among the severe scenarios."
    )
    add_paragraph(
        doc,
        "The spatial outputs support the statistical pattern. The upper floor origin forces infected agents and evacuees through a long shared connector sequence, spreading exposure across multiple occupied levels. The Canteen origin intersects central building traffic and produces strong but seed sensitive spread. The second floor origin remains comparatively localized because it begins near an exit and below most of the occupied classroom population. These findings describe the current simulation, not measured real world FEU Tech performance."
    )

    add_heading(doc, "Contents", 1)
    contents = [
        "1 Introduction",
        "2 Model Framework and Methodology",
        "3 Building and Population Representation",
        "4 Scenario and Transmission Criteria",
        "5 Statistical Results",
        "6 Graph and Heat Map Analysis",
        "7 Integrated Discussion",
        "8 Limitations and Validation Priorities",
        "9 Conclusion and Recommendations",
        "Appendix A Model Parameter Overview",
    ]
    for item in contents:
        p = doc.add_paragraph(item)
        p.paragraph_format.space_after = Pt(3)
        p.paragraph_format.left_indent = Inches(0.2)
    doc.add_page_break()

    add_heading(doc, "1 Introduction", 1)
    add_heading(doc, "1.1 Background", 2)
    add_paragraph(
        doc,
        "A high rise campus concentrates people in classrooms, offices, shared areas, corridors, elevators, and stairs. During a rapidly transmitted hostile outbreak, the location of the first infected person can change who encounters the threat, when congestion forms, and how long occupants remain exposed. An agent based model is suited to this question because it represents individuals moving through a structured building rather than treating the population as one homogeneous group."
    )
    add_paragraph(
        doc,
        "Surviving the Outbreak at FEU Tech converts the available floor plans into traversable grids and places occupants in modeled rooms and shared spaces. The model then follows individual movement, evacuation, cross floor transport, contact, infection, and exit events. The project is designed as a comparative simulation study. It does not predict an actual emergency; it tests how the same behavioral and capacity assumptions respond when the outbreak begins at different elevations."
    )
    add_heading(doc, "1.2 Objectives", 2)
    add_bullets(doc, [
        "Construct a usable multi floor agent based representation of FEU Tech from the supplied floor plans.",
        "Simulate 24 hours of movement, infection, evacuation, and vertical transport for a building population approaching 4,000 agents.",
        "Compare outbreak origins on the second, eighth, and sixteenth floors while holding the other scenario settings constant.",
        "Measure final population categories, infection timing, variability across seeds, floor level congestion, and spatial infection exposure.",
        "Produce graphs, heat maps, animations, and a defensible written interpretation of the model results."
    ])
    add_heading(doc, "1.3 Scope", 2)
    add_paragraph(
        doc,
        "The building representation contains 15 modeled physical levels: Ground, Floors 2 through 12, and Floors 14 through 16. The ground level is treated as a garage and contains no generated occupants. Fourteen levels contain occupied rooms or shared areas. The Floor 13 label is not used in the physical floor sequence. The primary occupancy draw is 3,713 agents, below the original 4,000 agent target because occupants are generated from the present per room ranges."
    )

    add_heading(doc, "2 Model Framework and Methodology", 1)
    add_heading(doc, "2.1 Agent States", 2)
    add_paragraph(
        doc,
        "Every agent is reported in exactly one final category. Non Infected agents remain inside without becoming infected. Infected agents have been converted after a successful bite or attack event. Escaped agents have been removed from the indoor simulation through an authorized exit. Population conservation is checked by confirming that these three categories sum to the initial population at the end of each run."
    )
    add_heading(doc, "2.2 Time and Update Sequence", 2)
    add_paragraph(
        doc,
        "A run lasts 24 simulated hours and uses a 10 minute time step, producing 144 update intervals. Each interval applies movement, connector and queue processing, infection contact checks, state updates, and data recording in the implemented order. Evacuation begins at Hour 1 in all three scenarios so that outbreak origin, rather than evacuation timing, is the intended controlled difference."
    )
    add_heading(doc, "2.3 Movement and Evacuation", 2)
    add_paragraph(
        doc,
        "Before evacuation, a non infected agent has an 8 percent chance of moving during each update. After evacuation begins, the movement probability rises to 70 percent. Infected agents have a 65 percent movement probability and a 75 percent pursuit tendency. Vertical movement occurs through stair and elevator connector regions. The current stair capacity is 24 agents per 10 minute step. Eight regular elevator shafts are represented on each upper floor with 15 agent capacity per shaft and a 20 minute dispatch interval. A green elevator is represented beside the right stair with 15 agent capacity and a 30 minute dispatch interval."
    )
    add_paragraph(
        doc,
        "The second floor Student Plaza exit can process 40 agents per update and the ground floor exit can process 30. These are provisional model capacities, not field measured values. Their purpose is to create finite throughput and queues that can be compared across scenarios."
    )
    add_heading(doc, "2.4 Infection Logic", 2)
    add_paragraph(
        doc,
        "Transmission is not a generic airborne rate. Infection requires an infected and non infected agent to occupy adjacent grid cells. Each adjacent infected neighbor produces a 12 percent bite or attack probability per 10 minute update, with the combined immediate probability capped at 35 percent. A successful bite converts the target to Infected with 100 percent probability. This deliberately aggressive rule reflects the fictional zombie premise and should not be interpreted as a human disease parameter."
    )
    add_paragraph(
        doc,
        "Entrapment raises risk over time. Beginning four hours after evacuation starts, the bite probability gains 3 percentage points for each additional hour, up to a 75 percent cap. The increase still requires adjacency to an infected agent. In practical terms, an occupant who remains inside longer is exposed to more movement cycles and faces a stronger attack probability during later contacts."
    )

    add_heading(doc, "3 Building and Population Representation", 1)
    add_heading(doc, "3.1 Floor Plan Framework", 2)
    add_paragraph(
        doc,
        "The supplied floor plans were converted to grid based traversable layouts with rooms, corridor margins, door access, elevators, stairs, and exits. Elevator footprints were kept outside occupied rooms and connected to hallway space to avoid the earlier overlap and access errors. Floor 11 uses the revised plan that removes the Computer Engineering room. Floor 12 is currently derived from the revised Floor 11 geometry and remains provisional until an independent Floor 12 plan is validated."
    )
    layout_atlas = OUTPUT / "layouts" / "all_floor_layout_atlas.png"
    if layout_atlas.exists():
        add_figure(doc, layout_atlas, "Figure 1. Modeled floor layout atlas for all represented physical levels.", 6.65)

    occupancy_rows = [
        ("Ground", "Garage", "0", "0", "0"),
        ("2", "Student Plaza", "1", "30 to 40", "34"),
        ("3", "Gym", "1", "30 to 40", "37"),
        ("4", "Classrooms", "11", "330 to 440", "401"),
        ("5", "Classrooms and offices", "12", "310 to 420", "364"),
        ("6", "Classrooms", "12", "360 to 480", "418"),
        ("7", "Classrooms and offices", "14", "370 to 500", "425"),
        ("8", "Canteen", "1", "80 to 100", "92"),
        ("9", "Classrooms and office", "12", "335 to 450", "393"),
        ("10", "Classrooms and office", "13", "365 to 490", "420"),
        ("11", "Classrooms and lounges", "14", "380 to 520", "443"),
        ("12", "Derived classrooms and lounges", "14", "380 to 520", "452"),
        ("14", "Library", "1", "80 to 100", "99"),
        ("15", "Offices", "9", "45 to 90", "57"),
        ("16", "Offices", "11", "55 to 110", "78"),
    ]
    add_heading(doc, "3.2 Occupant Distribution", 2)
    add_paragraph(
        doc,
        "The current occupancy specification contains 126 occupied spaces with a combined allowable range of 3,150 to 4,300 agents. The primary random seed generates 3,713 occupants. Floors 4 through 12 hold most of the population, while Floors 2, 3, 8, 14, 15, and 16 have smaller specialized populations. This uneven vertical distribution is important because it changes how quickly an origin intersects dense classroom traffic."
    )
    add_table(doc, ["Physical floor", "Primary use", "Occupied spaces", "Allowed range", "Primary draw"], occupancy_rows,
              widths=[0.75, 2.45, 1.05, 1.05, 0.9], font_size=8.5, numeric_cols={0, 2, 3, 4})
    add_paragraph(doc, "The primary draw totals 3,713 agents. The ground floor contributes no initial occupants and functions as a transport and exit level.")

    add_heading(doc, "4 Scenario and Transmission Criteria", 1)
    scenario_rows = [
        ("Second floor origin", "Student Plaza", "1 infected", "Hour 1", "24 hours"),
        ("Eighth floor origin", "Canteen", "1 infected", "Hour 1", "24 hours"),
        ("Sixteenth floor origin", "Random office", "1 infected", "Hour 1", "24 hours"),
    ]
    add_table(doc, ["Scenario", "Initial infected area", "Initial infected", "Evacuation start", "Duration"], scenario_rows,
              widths=[1.45, 1.55, 1.1, 1.2, 1.0], font_size=8.8, numeric_cols={2, 3, 4})
    add_paragraph(
        doc,
        "The scenario design isolates outbreak elevation. All three cases use the same movement, pursuit, connector, bite, entrapment, exit, and simulation duration settings. Random placement and movement still create stochastic variation, which is why results are reported for a primary seed and for three independent seeds."
    )

    add_heading(doc, "5 Statistical Results", 1)
    add_heading(doc, "5.1 Primary Seed Outcomes", 2)
    primary_rows = [
        ("Second floor", "3,713", "774", "20.85%", "2,853", "86", "2.32%"),
        ("Eighth floor", "3,713", "2,881", "77.59%", "591", "241", "6.49%"),
        ("Sixteenth floor", "3,713", "3,204", "86.29%", "300", "209", "5.63%"),
    ]
    add_table(doc, ["Origin", "Initial", "Infected", "Infection rate", "Non Infected", "Escaped", "Escape rate"], primary_rows,
              widths=[1.15, 0.72, 0.8, 0.92, 0.95, 0.72, 0.86], font_size=8.3, numeric_cols={1, 2, 3, 4, 5, 6})
    add_paragraph(
        doc,
        "The primary result shows a 65.45 percentage point infection gap between the second and sixteenth floor origins. The eighth floor result is 56.74 points above the second floor result and 8.70 points below the sixteenth floor result. Escape percentages remain low in all three scenarios, ranging from 2.32 to 6.49 percent. Because the implementation can currently classify an infected agent as Escaped at an exit, these totals should be read as exit throughput rather than confirmed survivor counts."
    )

    add_heading(doc, "5.2 Three Seed Replication", 2)
    replication_rows = [
        ("Second floor", "850.0 +/- 74.5", "22.68% +/- 1.95%", "115.0 +/- 42.7", "3.06% +/- 1.10%"),
        ("Eighth floor", "2,714.7 +/- 653.6", "72.39% +/- 16.98%", "193.0 +/- 42.3", "5.16% +/- 1.18%"),
        ("Sixteenth floor", "3,231.7 +/- 88.8", "86.25% +/- 1.57%", "217.7 +/- 12.5", "5.81% +/- 0.35%"),
    ]
    add_table(doc, ["Origin", "Mean infected +/- SD", "Mean infection rate +/- SD", "Mean escaped +/- SD", "Mean escape rate +/- SD"], replication_rows,
              widths=[1.05, 1.35, 1.55, 1.2, 1.35], font_size=8.2, numeric_cols={1, 2, 3, 4})
    add_paragraph(
        doc,
        "The replication populations are 3,713, 3,794, and 3,733, so percentage based comparisons are more appropriate than raw counts alone. The eighth floor outcome has the largest infection rate standard deviation at 16.98 percentage points, indicating substantial sensitivity to random placement and movement. The sixteenth floor mean is higher and much tighter at 86.25 percent plus or minus 1.57 points. The second floor remains the least severe in every tested seed."
    )

    add_heading(doc, "5.3 Temporal Statistics", 2)
    timing_rows = [
        ("Second floor", "Not reached", "Not reached", "Hour 23.33", "35"),
        ("Eighth floor", "Hour 20.33", "Hour 21.83", "Hour 20.67", "133"),
        ("Sixteenth floor", "Hour 15.83", "Hour 17.17", "Hour 16.67", "136"),
    ]
    add_table(doc, ["Origin", "25% infected", "50% infected", "Peak increase time", "Peak new infections per step"], timing_rows,
              widths=[1.15, 1.15, 1.15, 1.4, 1.25], font_size=8.5, numeric_cols={1, 2, 3, 4})
    add_paragraph(
        doc,
        "The sixteenth floor curve accelerates first, crossing 25 percent infection about 4.5 hours before the eighth floor case and reaching 50 percent about 4.7 hours earlier. Neither threshold is reached by the second floor case. All three runs experience their strongest growth late in the simulation, after the entrapment rule begins raising the bite probability. This timing supports a compounding interpretation: prolonged indoor exposure creates more contact cycles at progressively higher attack risk."
    )

    # Wide visual analysis section.
    landscape = doc.add_section(WD_SECTION.NEW_PAGE)
    configure_section(landscape, landscape=True)
    add_heading(doc, "6 Graph and Heat Map Analysis", 1)

    add_landscape_page(
        doc,
        "6.1 Comparative Outcome Dashboard",
        OUTPUT / "analysis" / "outbreak_origin_conclusive_dashboard.png",
        "Figure 2. Consolidated comparison of infection severity, escape throughput, infection progression, and three seed infection variability.",
        "The dashboard makes the scenario ordering visible at a glance. The primary bars show a sharp increase in infection severity as the origin moves upward. The progression panel shows the sixteenth floor curve entering rapid growth first, followed by the eighth floor curve. The error bars confirm that the eighth floor case is much less stable than the other scenarios, while the sixteenth floor case remains consistently severe.",
        width=8.15,
        first=True,
    )

    add_landscape_page(
        doc,
        "6.2 Primary Final Population Comparison",
        RESULTS / "scenario_outcome_comparison.png",
        "Figure 3. Final population categories in the primary seed for the three outbreak origins.",
        "The chart preserves the 3,713 agent total in each case. The second floor run retains a large Non Infected group, whereas the eighth and sixteenth floor runs transfer most of the population into the Infected category. The Escaped segment is small in every scenario and should be interpreted as exit throughput under the present state handling limitation.",
        width=9.0,
    )

    add_landscape_page(
        doc,
        "6.3 Three Seed Comparison",
        RESULTS / "replicated_scenario_comparison.png",
        "Figure 4. Mean final outcomes and variation across three random seeds.",
        "Replication does not change the scenario ranking. The wide eighth floor error range shows that the Canteen origin can produce different degrees of building wide spread depending on stochastic movement and contact. The narrow sixteenth floor range indicates that its high infection burden is not dependent on one unusual primary run.",
        width=8.9,
    )

    progression_notes = {
        "second_floor_outbreak": (
            "6.4 Second Floor Population Progression",
            "Figure 5. Population progression for the second floor outbreak.",
            "The second floor curve remains comparatively flat until late in the run and finishes below 25 percent infection. Starting beside the Student Plaza exit and below most occupants limits early access to the dense upper floor population. The late rise shows that the scenario is not harmless; accumulated exposure and connector movement can still expand infection over time."
        ),
        "eighth_floor_outbreak": (
            "6.5 Eighth Floor Population Progression",
            "Figure 6. Population progression for the eighth floor outbreak.",
            "The Canteen origin transitions to rapid growth around Hours 19 to 22. Its central position allows contact with downward evacuation traffic and with occupants moving through the transport core. Once the outbreak reaches densely occupied classroom floors, the infected curve rises sharply and the Non Infected curve falls in parallel."
        ),
        "sixteenth_floor_outbreak": (
            "6.6 Sixteenth Floor Population Progression",
            "Figure 7. Population progression for the sixteenth floor outbreak.",
            "The sixteenth floor origin enters rapid growth earliest and exceeds 50 percent infection by about Hour 17.17. Both infected agents and evacuees must descend through shared connectors, creating repeated opportunities for contact across many floors. The curve remains above the eighth floor trajectory through the end of the run."
        ),
    }
    for folder, (heading, caption, analysis) in progression_notes.items():
        add_landscape_page(doc, heading, RESULTS / folder / "population_progression.png", caption, analysis, width=7.7)

    heat_notes = {
        "second_floor_outbreak": (
            "6.7 Second Floor Infected Presence Heat Map",
            "Figure 8. Cumulative infected cell visits for the second floor outbreak.",
            "The heat map concentrates infected visits around the lower level origin, corridors, and connector access. Compared with the upper origin cases, high intensity exposure is less broadly distributed across the building. Bright cells represent repeated infected visits, not unique infected people and not a probability of infection."
        ),
        "eighth_floor_outbreak": (
            "6.8 Eighth Floor Infected Presence Heat Map",
            "Figure 9. Cumulative infected cell visits for the eighth floor outbreak.",
            "The central origin produces exposure above and below the Canteen. Repeated visits form around circulation paths and connector regions, showing how an initially localized outbreak can intersect evacuation traffic. The spatial spread is extensive but varies more across seeds than the sixteenth floor case."
        ),
        "sixteenth_floor_outbreak": (
            "6.9 Sixteenth Floor Infected Presence Heat Map",
            "Figure 10. Cumulative infected cell visits for the sixteenth floor outbreak.",
            "The upper origin produces a clear descending exposure pattern. High cumulative visits appear on multiple lower floors as infected agents traverse shared connectors and populated corridors. The distribution supports the statistical finding that this origin exposes a broad vertical sequence before occupants reach an exit."
        ),
    }
    for folder, (heading, caption, analysis) in heat_notes.items():
        add_landscape_page(doc, heading, RESULTS / folder / "spatial" / "infected_presence_heatmap_atlas.png", caption, analysis, width=9.3)

    pop_heat_notes = {
        "second_floor_outbreak": (
            "6.10 Second Floor Indoor Population by Floor",
            "Figure 11. Active indoor agents by physical floor and simulated hour for the second floor origin.",
            "This heat map shows redistribution and accumulation by floor rather than infection status. It helps distinguish exposure from congestion: a bright band indicates many agents remain active on that level. The second floor receives agents moving toward the exit, while upper occupied floors gradually lose population through downward movement and state changes."
        ),
        "eighth_floor_outbreak": (
            "6.11 Eighth Floor Indoor Population by Floor",
            "Figure 12. Active indoor agents by physical floor and simulated hour for the eighth floor origin.",
            "The strongest accumulation develops on lower floors, especially Floor 2, as occupants descend toward the Student Plaza exit. Persistent bands on Floors 4 through 7 indicate prolonged indoor presence. This produces the conditions required for the late entrapment multiplier to matter: agents remain indoors and continue encountering infected neighbors."
        ),
        "sixteenth_floor_outbreak": (
            "6.12 Sixteenth Floor Indoor Population by Floor",
            "Figure 13. Active indoor agents by physical floor and simulated hour for the sixteenth floor origin.",
            "The floor time pattern shows the downward transfer of active agents from upper floors into the lower circulation and exit levels. The long route from Floor 16 increases shared connector use before escape is possible. The heat map therefore links the early infection acceleration to sustained multi floor movement rather than to the small initial office population alone."
        ),
    }
    population_heatmap_section = doc.add_section(WD_SECTION.NEW_PAGE)
    configure_section(population_heatmap_section, landscape=True)
    for index, (folder, (heading, caption, analysis)) in enumerate(pop_heat_notes.items()):
        add_landscape_page(
            doc,
            heading,
            RESULTS / folder / "spatial" / "floor_population_over_time_heatmap.png",
            caption,
            analysis,
            width=9.15,
            first=index == 0,
        )

    transport_notes = {
        "second_floor_outbreak": (
            "6.13 Second Floor Transport and Queue Summary",
            "Figure 14. Connector use, queueing, and exit activity for the second floor origin.",
            "Transport metrics show how evacuation throughput interacts with the outbreak. Queueing extends indoor exposure even when occupants are attempting to leave. Because the origin is already near an exit, the second floor case avoids part of the vertical descent burden experienced by the other scenarios."
        ),
        "eighth_floor_outbreak": (
            "6.14 Eighth Floor Transport and Queue Summary",
            "Figure 15. Connector use, queueing, and exit activity for the eighth floor origin.",
            "The middle floor origin intersects both downward traffic and occupants arriving from upper levels. Connector and queue activity create repeated mixing zones. These modeled queues help explain why a 92 occupant origin space can lead to a large building wide infection burden."
        ),
        "sixteenth_floor_outbreak": (
            "6.15 Sixteenth Floor Transport and Queue Summary",
            "Figure 16. Connector use, queueing, and exit activity for the sixteenth floor origin.",
            "The sixteenth floor case imposes the longest descent on the initial threat and on nearby occupants. Repeated connector use distributes exposure down the building. The transport outputs reinforce the recommendation to study stair and elevator control as a major intervention variable in later model versions."
        ),
    }
    for folder, (heading, caption, analysis) in transport_notes.items():
        transport_section = doc.add_section(WD_SECTION.NEW_PAGE)
        configure_section(transport_section, landscape=True)
        add_landscape_page(
            doc,
            heading,
            RESULTS / folder / "spatial" / "transport_and_queue_summary.png",
            caption,
            analysis,
            width=9.15,
            first=True,
        )

    portrait = doc.add_section(WD_SECTION.NEW_PAGE)
    configure_section(portrait, landscape=False)

    add_heading(doc, "7 Integrated Discussion", 1)
    add_heading(doc, "7.1 Why the Origin Changes the Outcome", 2)
    add_paragraph(
        doc,
        "Outbreak elevation changes the number and sequence of shared spaces that must be crossed before escape. The second floor origin begins on the same level as a major exit and below most of the population. It therefore has fewer early opportunities to contact the dense classroom floors. The sixteenth floor origin begins above every major occupied classroom level. Descending infected agents and evacuees repeatedly share stairs, elevators, corridors, and lower floor queues. The eighth floor sits between these extremes and can spread in both directions through the building core."
    )
    add_heading(doc, "7.2 Role of Congestion and Entrapment", 2)
    add_paragraph(
        doc,
        "The model treats inability to escape as a growing hazard rather than an automatic infection event. An occupant who remains indoors experiences more time steps, more possible adjacency events, and a larger bite probability after the four hour entrapment threshold. This mechanism is visible in the late acceleration of all infection curves. It also means that connector and exit throughput affect infection indirectly by controlling how long agents remain exposed."
    )
    add_heading(doc, "7.3 Interpretation of Escape Rates", 2)
    add_paragraph(
        doc,
        "The eighth floor case has the highest primary escape percentage even though it also has a severe infection burden. This is not contradictory: a scenario can move more agents through exits while simultaneously creating high contact rates among those who remain. Escape rate alone is therefore not a sufficient safety measure. It must be read alongside infection rate, timing, congestion, and state handling. The present implementation also permits infected agents to become Escaped, so exit counts are not confirmed survivor counts."
    )
    add_heading(doc, "7.4 Statistical Strength of the Findings", 2)
    add_paragraph(
        doc,
        "The three tested seeds are enough to identify a consistent ordering but not enough for formal confidence intervals or a stable estimate of rare outcomes. The sixteenth floor result is comparatively robust because its mean is high and its standard deviation is small. The eighth floor result requires more replication because its standard deviation is large. At least 30 seeds per scenario should be used in a final inferential study, ideally with fixed occupancy or normalized rates so movement randomness can be separated from population draw randomness."
    )

    add_heading(doc, "8 Limitations and Validation Priorities", 1)
    limitations = [
        "Only three random seeds were evaluated. This supports descriptive comparison but not precise uncertainty estimates.",
        "The primary population is 3,713 rather than the exact 4,000 agent target, and the total varies slightly across seeds because room populations are redrawn.",
        "Infected agents can currently be converted to Escaped at an exit. Future versions should track infected exits separately or prevent this transition.",
        "Infected agents begin vertical connector use only after the Hour 1 evacuation start, which may suppress early cross floor spread.",
        "Regular elevator capacity is aggregated independently by source floor rather than tracking eight individual cars and their trajectories.",
        "The entrapment multiplier uses global time since evacuation instead of each agent's personal waiting or queue duration.",
        "Walking speed, stair flow, elevator timing, exit capacity, pursuit behavior, and bite probability are provisional assumptions rather than calibrated FEU Tech measurements.",
        "Floor 12 is derived from Floor 11 and should be replaced when an independently verified Floor 12 drawing is available.",
        "Heat maps record cumulative cell visits. They identify repeated exposure locations but do not represent unique persons, measured density, or infection probability by themselves.",
    ]
    add_bullets(doc, limitations)
    add_heading(doc, "8.1 Recommended Validation Sequence", 2)
    add_bullets(doc, [
        "Correct the infected exit state and record survivor escapes separately from infected exits.",
        "Hold the initial floor populations constant across scenarios and seeds, then run at least 30 movement seeds per scenario.",
        "Validate every floor's room, door, hallway, stair, elevator, and exit connectivity against the latest drawings.",
        "Replace global entrapment time with individual exposure or queue duration and compare the resulting curves.",
        "Calibrate connector and exit throughput using observed dimensions, walking speed assumptions, or evacuation references.",
        "Conduct sensitivity analysis on bite probability, pursuit probability, evacuation start, stair capacity, elevator availability, and exit capacity."
    ])

    doc.add_page_break()
    add_heading(doc, "9 Conclusion and Recommendations", 1)
    add_paragraph(
        doc,
        "The completed model demonstrates that outbreak origin is a major determinant of simulated infection severity at FEU Tech. Under the present assumptions, a sixteenth floor origin is the highest risk and most consistently severe case, producing 86.29 percent infection in the primary run and a three seed mean of 86.25 percent. An eighth floor Canteen origin is also dangerous, with 77.59 percent infection in the primary run, but its three seed standard deviation shows that its outcome is more sensitive to stochastic movement and placement. A second floor Student Plaza origin produces substantially lower infection because it begins near an authorized exit and below most occupants."
    )
    add_paragraph(
        doc,
        "The graphs and heat maps explain why. The upper origin reaches rapid growth earlier, spreads infected presence across more floor levels, and requires both the threat and evacuees to share a long downward connector sequence. The central Canteen origin intersects traffic from both directions. The lower origin remains more localized, although infection still accelerates late when trapped occupants face more contact cycles and the increasing attack multiplier."
    )
    add_paragraph(
        doc,
        "The current evidence supports prioritizing early isolation of upper floor origins, controlled access to shared stairs and elevators, rapid clearing of lower floor queues, and scenario specific evacuation management. These are model based recommendations for further testing, not operational instructions for a real emergency. Before the project is treated as a validated decision model, the state transition, elevator, entrapment, population, and replication limitations listed in this report should be corrected and the resulting scenarios rerun."
    )

    doc.add_page_break()
    add_heading(doc, "Appendix A Model Parameter Overview", 1)
    parameter_rows = [
        ("Simulation duration", "24 hours", "Common to all scenarios"),
        ("Time step", "10 minutes", "144 updates per run"),
        ("Primary population", "3,713 agents", "Generated from room ranges"),
        ("Agent categories", "Infected, Non Infected, Escaped", "Mutually exclusive final reporting states"),
        ("Initial infected", "1 agent", "Placed in the designated scenario origin"),
        ("Evacuation start", "Hour 1", "Same in all scenarios"),
        ("Normal movement", "8% per step", "Non infected before evacuation"),
        ("Evacuation movement", "70% per step", "Non infected after evacuation"),
        ("Infected movement", "65% per step", "Infected agents"),
        ("Pursuit tendency", "75%", "Bias toward nearby non infected agents"),
        ("Bite probability", "12% per adjacent infected", "Applied each 10 minute update"),
        ("Immediate bite cap", "35%", "Caps combined adjacent attack risk"),
        ("Conversion after bite", "100%", "Successful bite causes infection"),
        ("Entrapment threshold", "4 evacuation hours", "Risk increase begins after threshold"),
        ("Entrapment increase", "+3 percentage points per hour", "Requires infected adjacency"),
        ("Entrapment cap", "75%", "Maximum modeled bite probability"),
        ("Stair capacity", "24 agents per step", "Provisional"),
        ("Regular elevators", "8 shafts per upper floor", "15 agents each; 20 minute dispatch"),
        ("Green elevator", "1 per upper floor", "15 agents; 30 minute dispatch"),
        ("Second floor exit", "40 agents per step", "Student Plaza exit"),
        ("Ground floor exit", "30 agents per step", "Garage level exit"),
    ]
    add_table(doc, ["Factor", "Current value", "How it functions"], parameter_rows,
              widths=[1.75, 1.75, 3.15], font_size=8.5, numeric_cols=set())

    doc.save(REPORT_PATH)
    print(REPORT_PATH)


if __name__ == "__main__":
    main()
