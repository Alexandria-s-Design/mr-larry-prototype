"""
Generate the Life Dreams Wealth curriculum proposal for Mr. Larry Wimsatt.
"""

import os
from docx import Document
from docx.shared import Inches, Pt, Cm, RGBColor, Emu
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.enum.section import WD_ORIENT
from docx.oxml.ns import qn, nsdecls
from docx.oxml import parse_xml

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(REPO, "Life_Dreams_Wealth_Curriculum_Proposal.docx")

# Brand colors
NAVY = RGBColor(0x0F, 0x0F, 0x1A)
GOLD = RGBColor(0xC9, 0xA8, 0x4C)
DARK_GOLD = RGBColor(0xA0, 0x85, 0x3D)
TEAL = RGBColor(0x2A, 0x9D, 0x8F)
WHITE = RGBColor(0xFF, 0xFF, 0xFF)
LIGHT_GRAY = RGBColor(0xF5, 0xF5, 0xF5)
DARK_TEXT = RGBColor(0x1A, 0x1A, 0x2E)
MID_GRAY = RGBColor(0x55, 0x55, 0x55)

doc = Document()

# --- Page setup ---
for section in doc.sections:
    section.top_margin = Cm(2.0)
    section.bottom_margin = Cm(2.0)
    section.left_margin = Cm(2.5)
    section.right_margin = Cm(2.5)

style = doc.styles['Normal']
style.font.name = 'Calibri'
style.font.size = Pt(11)
style.font.color.rgb = DARK_TEXT
style.paragraph_format.space_after = Pt(6)
style.paragraph_format.line_spacing = 1.15


def set_cell_shading(cell, color_hex):
    shading = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{color_hex}"/>')
    cell._tc.get_or_add_tcPr().append(shading)


def add_styled_heading(text, level=1):
    h = doc.add_heading(text, level=level)
    for run in h.runs:
        if level == 1:
            run.font.color.rgb = NAVY
            run.font.size = Pt(22)
        elif level == 2:
            run.font.color.rgb = DARK_GOLD
            run.font.size = Pt(16)
        elif level == 3:
            run.font.color.rgb = TEAL
            run.font.size = Pt(13)
        run.font.name = 'Calibri'
    return h


def add_body(text, bold=False, italic=False):
    p = doc.add_paragraph()
    run = p.add_run(text)
    run.bold = bold
    run.italic = italic
    run.font.size = Pt(11)
    run.font.name = 'Calibri'
    run.font.color.rgb = DARK_TEXT
    return p


def add_bullet(text, bold_prefix=""):
    p = doc.add_paragraph(style='List Bullet')
    if bold_prefix:
        run = p.add_run(bold_prefix)
        run.bold = True
        run.font.size = Pt(11)
        run.font.name = 'Calibri'
        run.font.color.rgb = DARK_TEXT
        run = p.add_run(text)
        run.font.size = Pt(11)
        run.font.name = 'Calibri'
        run.font.color.rgb = DARK_TEXT
    else:
        for run in p.runs:
            run.font.size = Pt(11)
            run.font.name = 'Calibri'
    return p


def add_table(headers, rows, col_widths=None):
    table = doc.add_table(rows=1 + len(rows), cols=len(headers))
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.style = 'Table Grid'

    # Header row
    for i, h in enumerate(headers):
        cell = table.rows[0].cells[i]
        cell.text = ""
        p = cell.paragraphs[0]
        run = p.add_run(h)
        run.bold = True
        run.font.size = Pt(10)
        run.font.color.rgb = WHITE
        run.font.name = 'Calibri'
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        set_cell_shading(cell, "0F0F1A")

    # Data rows
    for r_idx, row in enumerate(rows):
        for c_idx, val in enumerate(row):
            cell = table.rows[r_idx + 1].cells[c_idx]
            cell.text = ""
            p = cell.paragraphs[0]
            run = p.add_run(str(val))
            run.font.size = Pt(10)
            run.font.name = 'Calibri'
            run.font.color.rgb = DARK_TEXT
            if r_idx % 2 == 0:
                set_cell_shading(cell, "F5F5F0")

    if col_widths:
        for i, w in enumerate(col_widths):
            for row in table.rows:
                row.cells[i].width = Inches(w)

    return table


# ============================================================
# COVER PAGE
# ============================================================

# Spacer
for _ in range(4):
    doc.add_paragraph()

title = doc.add_paragraph()
title.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = title.add_run("LIFE DREAMS WEALTH")
run.font.size = Pt(36)
run.font.color.rgb = NAVY
run.bold = True
run.font.name = 'Calibri'

subtitle = doc.add_paragraph()
subtitle.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = subtitle.add_run("A Family Financial Literacy Curriculum & Platform")
run.font.size = Pt(18)
run.font.color.rgb = DARK_GOLD
run.font.name = 'Calibri'

doc.add_paragraph()

divider = doc.add_paragraph()
divider.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = divider.add_run("_" * 60)
run.font.color.rgb = TEAL
run.font.size = Pt(10)

doc.add_paragraph()

details = [
    ("Prepared for:", "Mr. Lawrence (Larry) Wimsatt"),
    ("", "Life Dreams Wealth"),
    ("", "Long Beach, CA"),
    ("", ""),
    ("Prepared by:", "Alexandria's Design LLC"),
    ("", "Dr. Charles Martin"),
    ("", "Moreno Valley, CA"),
    ("", "310-709-4893"),
    ("", ""),
    ("Date:", "March 7, 2026"),
    ("Version:", "1.0 — Curriculum & Platform Proposal"),
]

for label, value in details:
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    if label:
        run = p.add_run(label + " ")
        run.bold = True
        run.font.size = Pt(11)
        run.font.color.rgb = NAVY
        run.font.name = 'Calibri'
    run = p.add_run(value)
    run.font.size = Pt(11)
    run.font.color.rgb = DARK_TEXT
    run.font.name = 'Calibri'
    p.paragraph_format.space_after = Pt(1)

doc.add_page_break()

# ============================================================
# TABLE OF CONTENTS (manual)
# ============================================================

add_styled_heading("Table of Contents", 1)
toc_items = [
    "1. Executive Summary",
    "2. Vision & Philosophy",
    "3. The Life-Dreams-Wealth Framework",
    "4. Target Audience",
    "5. Platform Architecture — Dual-Portal Family App",
    "6. Curriculum Map — 13 Topics (52 Weeks)",
    "7. Lesson Design & Delivery Model",
    "8. Interactive Simulations & Prior Work",
    "9. Technology Stack & Deployment",
    "10. Competitive Differentiation",
    "11. Development Roadmap & Timeline",
    "12. Investment & Pricing",
    "13. Next Steps",
]
for item in toc_items:
    p = doc.add_paragraph()
    run = p.add_run(item)
    run.font.size = Pt(12)
    run.font.name = 'Calibri'
    run.font.color.rgb = DARK_TEXT
    p.paragraph_format.space_after = Pt(4)

doc.add_page_break()

# ============================================================
# 1. EXECUTIVE SUMMARY
# ============================================================

add_styled_heading("1. Executive Summary", 1)

add_body(
    "Life Dreams Wealth (LDW) is a family-centered financial literacy curriculum and interactive "
    "platform designed to transform how families — particularly in African American and Hispanic American "
    "communities — learn about, talk about, and build financial health together."
)

add_body(
    "Created by Mr. Lawrence Wimsatt, LDW is built on a simple but powerful insight: financial literacy "
    "is not just about money — it is about mindset, identity, and family. By engaging both parents and children "
    "through parallel learning portals, real-world simulations, and goal-setting tools, LDW creates an ecosystem "
    "where financial knowledge flows naturally within the family unit."
)

add_body(
    "This proposal outlines the full curriculum (13 topics across 52 weeks), the dual-portal mobile platform "
    "design, the technology approach, and a phased development roadmap to bring Mr. Wimsatt's vision to life "
    "as a market-ready product."
)

doc.add_paragraph()

# Key highlights box
add_styled_heading("At a Glance", 3)
highlights = [
    ("13 Topics", " across 3 phases (Life, Dreams, Wealth), each ~4 weeks"),
    ("Dual-Portal App: ", "Parent Portal + Child Portal with shared family dashboard"),
    ("Immersive Learning: ", "3D virtual hallway navigation, branching simulations, interactive scenarios"),
    ("Family-First: ", "Chore-based payroll, shared savings goals, parent progress tracking"),
    ("Community Focus: ", "Breaking financial barriers in diverse, underserved communities"),
    ("Deployment: ", "Mobile app (iOS/Android), web app, SCORM-compatible for schools/orgs"),
]
for bold_part, rest in highlights:
    add_bullet(rest, bold_prefix=bold_part)

doc.add_page_break()

# ============================================================
# 2. VISION & PHILOSOPHY
# ============================================================

add_styled_heading("2. Vision & Philosophy", 1)

add_body(
    '"Breaking Financial Barriers: Empowering Diverse Communities"',
    bold=True
)

add_body(
    "Mr. Wimsatt's philosophy begins with a foundational truth: before you can build wealth, "
    "you must first understand your life — where you are, what you value, and what you're working toward. "
    "Financial education fails when it starts with spreadsheets. It succeeds when it starts with identity."
)

add_styled_heading("The Iceberg Model", 3)
add_body(
    "A recurring metaphor throughout LDW is the iceberg. What most people see of someone's "
    "financial life — their car, their home, their clothes — is only the tip. Beneath the surface lies "
    "the real substance: savings habits, investment knowledge, generational wealth strategies, debt management, "
    "and the mindset that drives every financial decision. LDW teaches families to build from the bottom up."
)

add_styled_heading("Family as the Unit of Learning", 3)
add_body(
    "Unlike most financial literacy programs that target individuals, LDW treats the family as the learning unit. "
    "Parents learn to manage household finances, allocate allowances, and model financial behavior. "
    "Children learn to earn, save, spend wisely, and invest — all within a safe, gamified environment "
    "that mirrors real financial systems."
)

doc.add_page_break()

# ============================================================
# 3. THE FRAMEWORK
# ============================================================

add_styled_heading("3. The Life-Dreams-Wealth Framework", 1)

add_body(
    "Every topic in the curriculum maps to one of three phases. This is the heartbeat of the program:"
)

doc.add_paragraph()

framework_headers = ["Phase", "Core Question", "Focus", "Goal Types"]
framework_rows = [
    ["LIFE", "Where are you now?", "Self-assessment, current financial reality, money mindset, habits & identity", "Awareness & honesty"],
    ["DREAMS", "Where do you want to go?", "Goal-setting, planning, aspiration, career exploration", "Short (4 wk), Intermediate (10-12 wk), Long (26 wk)"],
    ["WEALTH", "How do you build resources?", "Savings, investing, action plans, resource identification, community tools", "Action plans that fit into current life"],
]
add_table(framework_headers, framework_rows, col_widths=[1.0, 1.5, 2.5, 1.5])

doc.add_paragraph()

add_body(
    "The framework is designed to be cyclical — after completing all 13 topics, families can revisit "
    "with deeper goals. A child who starts at age 8 can progress through age-appropriate versions of the "
    "same framework through age 18, building sophistication over time."
)

add_styled_heading("Mindset First", 3)
add_body(
    "The very first interaction in the platform is not a lesson — it is a mindset exercise. "
    "Users are asked to define Life, Dreams, and Wealth in their own words before any content is delivered. "
    "This personal framing becomes the lens through which all subsequent learning is interpreted."
)

doc.add_page_break()

# ============================================================
# 4. TARGET AUDIENCE
# ============================================================

add_styled_heading("4. Target Audience", 1)

add_styled_heading("Primary: Families", 3)
add_bullet(" Parents/guardians seeking practical financial literacy tools for their household", bold_prefix="Parents:")
add_bullet(" Ages 6-18, learning financial concepts through age-appropriate, gamified experiences", bold_prefix="Children:")
add_bullet(" Learning together through shared activities, conversations, and goal tracking", bold_prefix="Family Unit:")

add_styled_heading("Secondary: Organizations & Schools", 3)
add_bullet(" After-school programs, community centers, faith-based organizations", bold_prefix="Community Orgs:")
add_bullet(" Financial literacy electives, career readiness programs, family engagement initiatives", bold_prefix="K-12 Schools:")
add_bullet(" Employee financial wellness programs", bold_prefix="Employers:")

add_styled_heading("Cultural Context", 3)
add_body(
    "LDW is designed with intentional cultural responsiveness for African American and Hispanic American "
    "communities — populations disproportionately affected by predatory lending, wealth gaps, and lack of "
    "access to financial education. Content, imagery, scenarios, and language reflect the lived experiences "
    "of these communities without being exclusionary. The platform is for everyone, but it is designed with "
    "these communities at the center."
)

doc.add_page_break()

# ============================================================
# 5. PLATFORM ARCHITECTURE
# ============================================================

add_styled_heading("5. Platform Architecture — Dual-Portal Family App", 1)

add_body(
    "The LDW platform is a mobile-first application with two interconnected portals, "
    "accessed through a shared Family Account."
)

add_styled_heading("Login & Onboarding", 3)
add_body(
    "Upon opening the app, the user enters their Family Name and selects either the Parent or Kids portal. "
    "An intro page features Mr. Larry's welcome message, a LinkedIn QR code, and a mindset-setting exercise "
    "where the family defines Life, Dreams, and Wealth in their own words."
)

doc.add_paragraph()

# Parent Portal
add_styled_heading("Parent's Portal", 2)
portal_headers = ["Feature", "Description"]
parent_rows = [
    ["Weekly Task Manager", "Create and manage household financial tasks (budgeting exercises, bill review, savings check-ins)"],
    ["Weekly Task Allocator", "Assign age-appropriate financial tasks/chores to each child with dollar values"],
    ["Payroll / Allowance", "Process weekly \"payroll\" for children based on completed tasks — teaches employer/employee relationship"],
    ["Progress Dashboard", "View each child's learning progress, completed topics, savings balance, and investment portfolio"],
    ["Family Goals", "Set shared family financial goals with visual progress tracking"],
    ["Resource Library", "Curated articles, videos, and tools for adult financial literacy"],
]
add_table(portal_headers, parent_rows, col_widths=[1.8, 4.7])

doc.add_paragraph()

# Child Portal
add_styled_heading("Child's Portal", 2)
child_rows = [
    ["Weekly Task Manager", "View assigned tasks, mark as complete, track weekly earnings"],
    ["Paystubs / Allowance", "View itemized paystubs showing what was earned, deductions (if applicable), and net \"pay\""],
    ["Savings Account", "Virtual savings account with interest accumulation — visual graphs show growth over time"],
    ["Gaming / Shopping", "Simulated marketplace where children spend virtual currency — teaches budgeting, wants vs. needs"],
    ["Investments", "Age-appropriate investment simulator — buy \"stocks\" in real companies, track gains/losses with virtual money"],
    ["3D Hallway", "Navigate the immersive virtual hallway to access curriculum topics — each door leads to a new subject"],
]
add_table(portal_headers, child_rows, col_widths=[1.8, 4.7])

doc.add_page_break()

# ============================================================
# 6. CURRICULUM MAP
# ============================================================

add_styled_heading("6. Curriculum Map — 13 Topics (52 Weeks)", 1)

add_body(
    "Each topic runs approximately 4 weeks and follows the Life-Dreams-Wealth progression. "
    "Topics build on each other but can also function as standalone modules for organizations "
    "that want to adopt individual units."
)

doc.add_paragraph()

# Phase 1: LIFE
add_styled_heading("Phase 1: LIFE — \"Where Are You Now?\" (Topics 1-4, Weeks 1-16)", 2)

life_headers = ["Topic", "Title", "Description", "Key Activities"]
life_rows = [
    ["1", "Mindset Reset: Defining Life, Dreams & Wealth",
     "Establish the foundation — before money comes mindset. Families define what Life, Dreams, and Wealth mean to them personally.",
     "Self-assessment survey, family values card sort, \"My Money Story\" journal, Mr. Larry welcome video"],
    ["2", "Your Financial Reality Check",
     "Honest look at where the family stands today — income, expenses, debts, habits. No judgment, just awareness.",
     "Income mapping worksheet, expense tracker challenge, \"Where Does the Money Go?\" simulation, parent-child money conversation guide"],
    ["3", "Needs vs. Wants: The Grocery Store Simulation",
     "Interactive branching simulation set in a grocery store. Make real purchasing decisions balancing nutrition, price, time, and quality.",
     "HealthMart Foods simulation (existing module), price comparison activities, meal planning on a budget, coupon strategy game"],
    ["4", "The Paycheck: Understanding Income",
     "Decode a paycheck — gross vs. net, taxes, deductions. Children set up their first \"payroll\" through the chore system.",
     "Paycheck anatomy lesson, tax basics for kids, child portal: first chore assignment and payday, parent portal: setting up task allocator"],
]
add_table(life_headers, life_rows, col_widths=[0.5, 1.5, 2.2, 2.3])

doc.add_paragraph()

# Phase 2: DREAMS
add_styled_heading("Phase 2: DREAMS — \"Where Do You Want to Go?\" (Topics 5-9, Weeks 17-36)", 2)

dreams_rows = [
    ["5", "Short-Term Goals: The 4-Week Sprint",
     "Set and achieve a small, tangible financial goal within 4 weeks. Experience the full goal-setting cycle.",
     "SMART goal workshop, savings jar challenge, weekly check-in routine, celebration and reflection"],
    ["6", "Intermediate Goals: Planning Bigger",
     "Extend the horizon to 10-12 weeks. Introduce compound interest and the power of patience.",
     "Compound interest calculator, \"Save for It\" simulation, delayed gratification exercises, vision board creation"],
    ["7", "Long-Term Dreams: The 26-Week Vision",
     "Think big — college, homeownership, entrepreneurship, generational wealth. What does your family's future look like?",
     "Dream board creation, career exploration (kids), home buying basics (parents), retirement intro, family 5-year plan"],
    ["8", "Breaking Financial Barriers",
     "Address systemic financial inequities honestly. Understand credit scores, predatory lending, and community resources.",
     "Credit score demystified, predatory lending red flags, community resource mapping, \"Know Your Rights\" financial toolkit"],
    ["9", "The Entrepreneur's Mindset",
     "Explore entrepreneurship as a wealth-building path. Kids run a simulated business; parents explore side income.",
     "Business idea brainstorm, lemonade stand simulation, revenue vs. profit lesson, mini business plan, Shark Tank-style family pitch night"],
]
add_table(life_headers, dreams_rows, col_widths=[0.5, 1.5, 2.2, 2.3])

doc.add_page_break()

# Phase 3: WEALTH
add_styled_heading("Phase 3: WEALTH — \"Building Your Resources\" (Topics 10-13, Weeks 37-52)", 2)

wealth_rows = [
    ["10", "Savings Strategies & Emergency Funds",
     "\"Pay yourself first.\" Build a savings habit and understand why emergency funds matter.",
     "Savings account setup (child portal), emergency scenario simulations, savings rate calculator, family savings challenge"],
    ["11", "Investing 101: Making Money Work",
     "Introduction to stocks, bonds, and compound growth. Kids manage a virtual investment portfolio.",
     "Stock market basics, virtual portfolio in child portal, risk vs. reward game, real-world company research project"],
    ["12", "Your Family Action Plan",
     "Synthesize everything into a personalized family financial action plan. How do your goals fit into your current life?",
     "Family financial plan template, budget creation workshop, resource inventory (what help is available?), accountability partner setup"],
    ["13", "Wealth Review & Graduation",
     "Celebrate progress, review growth, and set the stage for the next cycle. Graduation ceremony.",
     "Portfolio review, progress celebration, 6-month check-in plan, community sharing event, certificate of completion"],
]
add_table(life_headers, wealth_rows, col_widths=[0.5, 1.5, 2.2, 2.3])

doc.add_page_break()

# ============================================================
# 7. LESSON DESIGN
# ============================================================

add_styled_heading("7. Lesson Design & Delivery Model", 1)

add_body("Each 4-week topic follows a consistent rhythm that balances instruction, practice, family engagement, and assessment:")

doc.add_paragraph()

week_headers = ["Week", "Theme", "Activities", "Portal Integration"]
week_rows = [
    ["Week 1", "LEARN", "Mr. Larry intro video, core concept lesson in 3D hallway, vocabulary builder, pre-assessment",
     "Child: 3D hallway lesson\nParent: Resource article + family discussion prompt"],
    ["Week 2", "PRACTICE", "Interactive simulation or branching scenario, hands-on exercises, skill-building",
     "Child: Simulation + practice tasks\nParent: Parallel adult-level exercise"],
    ["Week 3", "FAMILY", "Shared parent-child activity, real-world application, family conversation guide",
     "Both portals: Shared family challenge, discussion tracker, photo/journal upload"],
    ["Week 4", "REFLECT", "Assessment quiz, reflection journal, goal-setting for next topic, celebration",
     "Child: Quiz + reflection\nParent: Progress review + family goal update"],
]
add_table(week_headers, week_rows, col_widths=[0.8, 0.9, 2.5, 2.3])

doc.add_paragraph()

add_styled_heading("The 3D Virtual Hallway", 3)
add_body(
    "The primary navigation experience for learners is an immersive 3D hallway. As users walk through "
    "the virtual corridor, they see numbered subject doors on the walls (Subject #1 through #13). "
    "Completed subjects show visual indicators of progress. This creates a sense of journey and "
    "accomplishment — you are literally walking through your financial education."
)

add_styled_heading("Mr. Larry as Guide", 3)
add_body(
    "Mr. Larry Wimsatt appears throughout the curriculum as a virtual guide and mentor. "
    "Through video introductions, narrated scenarios, and motivational check-ins, he provides "
    "the human connection that makes this more than just an app — it is a mentorship experience."
)

doc.add_page_break()

# ============================================================
# 8. SIMULATIONS & PRIOR WORK
# ============================================================

add_styled_heading("8. Interactive Simulations & Prior Work", 1)

add_body(
    "Significant prior development work has been completed, providing a strong foundation to build upon:"
)

add_styled_heading("Existing Assets", 3)
sim_headers = ["Asset", "Status", "Description"]
sim_rows = [
    ["Nutrition / Grocery Store Simulation", "Complete", "Branching scenario in Adobe Captivate — users navigate HealthMart Foods making purchasing decisions across green beans, chicken, salad, bread, drinks, milk, fruit, and toilet paper. Tracks price, prep time, and health score."],
    ["VR / 360 Simulation", "Complete", "SCORM 1.2-packaged Captivate simulation with panoramic environment, quiz interactions, and LMS-ready deployment."],
    ["Simulation Branching Logic", "Complete", "Detailed Excel spreadsheet mapping all decision branches, scoring rubrics, and outcome paths for the nutrition modules."],
    ["Logo & Brand Assets", "Complete", "19 logo variations, character heads, iceberg concept graphics, social media templates, and font selections."],
    ["Life Presentation Deck", "Complete", "PowerPoint presentation covering the LDW concept, competitive positioning, and pitch materials."],
    ["Powtoons Header Video", "Complete", "Animated promotional header video for marketing use."],
    ["Parent & Child Portal Mockups", "Prototype", "Functional mockups showing Parent Portal (Task Manager, Task Allocator, Payroll) and Child Portal (Tasks, Paystubs, Savings, Gaming/Shopping, Investments)."],
    ["360 Interactive eLearning Prototype", "Complete", "16-interaction-type prototype with draggable panorama, assessments, calculators, flashcards, and gamification elements."],
]
add_table(sim_headers, sim_rows, col_widths=[2.0, 0.9, 3.6])

doc.add_page_break()

# ============================================================
# 9. TECHNOLOGY
# ============================================================

add_styled_heading("9. Technology Stack & Deployment", 1)

add_styled_heading("Platform Options", 3)
tech_headers = ["Component", "Recommended Approach", "Notes"]
tech_rows = [
    ["Mobile App", "React Native or Flutter", "Single codebase for iOS + Android; cost-effective"],
    ["Web App", "Next.js / React", "Responsive web version for desktop/laptop access"],
    ["3D Hallway", "Three.js / WebGL", "Immersive 3D environment running in-browser"],
    ["Simulations", "Custom HTML5 + existing Captivate exports", "Leverage existing SCORM modules; build new sims in HTML5"],
    ["Backend", "Node.js + PostgreSQL", "User accounts, family data, progress tracking, payroll system"],
    ["Video/Avatar", "AI-generated narration + lip-sync", "Mr. Larry's avatar for guided lessons using AI video technology"],
    ["LMS Export", "SCORM 1.2 / xAPI", "For school and organizational deployment"],
    ["Hosting", "Cloud (AWS/Vercel)", "Scalable, secure, COPPA-compliant for children's data"],
]
add_table(tech_headers, tech_rows, col_widths=[1.3, 2.0, 3.2])

doc.add_page_break()

# ============================================================
# 10. COMPETITIVE DIFFERENTIATION
# ============================================================

add_styled_heading("10. Competitive Differentiation", 1)

add_body(
    "The financial literacy market includes free tools, school curricula, and apps — but none combine "
    "what LDW offers. Here is what makes LDW unique:"
)

doc.add_paragraph()

comp_headers = ["Differentiator", "LDW", "Typical Competitors"]
comp_rows = [
    ["Family Unit", "Both parents AND children learn together through connected portals", "Individual-focused; parent or child, not both"],
    ["Chore-Based Economy", "Real payroll system — kids earn, save, spend, and invest virtual currency tied to real tasks", "Abstract concepts with no real-world application"],
    ["Cultural Responsiveness", "Designed for and with AA/HA communities; scenarios reflect real lived experiences", "Generic, one-size-fits-all content"],
    ["Immersive Experience", "3D hallway, branching simulations, VR elements, gamification", "PDF worksheets or basic quizzes"],
    ["Sustained Learning", "52-week curriculum taught over time with progress tracking", "One-time workshops or self-paced modules with no accountability"],
    ["Mentorship Model", "Mr. Larry as a persistent virtual guide throughout the journey", "No human connection; content-only delivery"],
    ["Paid / Premium", "Premium product signaling quality and commitment", "Free tools with limited depth or engagement"],
]
add_table(comp_headers, comp_rows, col_widths=[1.3, 2.5, 2.7])

doc.add_page_break()

# ============================================================
# 11. ROADMAP
# ============================================================

add_styled_heading("11. Development Roadmap & Timeline", 1)

add_body("We recommend a phased approach that delivers value early while building toward the full platform:")

doc.add_paragraph()

road_headers = ["Phase", "Timeline", "Deliverables"]
road_rows = [
    ["Phase 1: Foundation", "Months 1-3",
     "Finalize curriculum for all 13 topics\nDesign UI/UX for both portals\nBuild Topic 1 (Mindset Reset) as fully functional prototype\nRefine existing simulation assets for integration"],
    ["Phase 2: Core Platform", "Months 4-8",
     "Develop mobile app (Parent + Child portals)\nBuild 3D hallway navigation\nImplement payroll/allowance system\nBuild Topics 2-4 (complete LIFE phase)\nAlpha testing with pilot families"],
    ["Phase 3: Content Expansion", "Months 9-14",
     "Build Topics 5-9 (DREAMS phase)\nIntegrate investment simulator\nBuild Topics 10-13 (WEALTH phase)\nBeta testing with broader audience"],
    ["Phase 4: Launch & Scale", "Months 15-18",
     "Public launch on iOS + Android + Web\nSCORM packaging for school/org distribution\nMarketing campaign\nCommunity partnerships\nOngoing content updates and age-level expansions"],
]
add_table(road_headers, road_rows, col_widths=[1.3, 1.2, 4.0])

doc.add_page_break()

# ============================================================
# 12. INVESTMENT & PRICING
# ============================================================

add_styled_heading("12. Investment & Pricing", 1)

add_body(
    "The following estimates reflect the scope of building a production-quality curriculum and platform. "
    "These are starting points for discussion and can be adjusted based on priorities and phasing."
)

doc.add_paragraph()

price_headers = ["Component", "Description", "Estimated Investment"]
price_rows = [
    ["Curriculum Design (13 Topics)", "Storyboarding, instructional design, content writing, learning sequences, assessments for all 13 topics", "$25,000 - $40,000"],
    ["UI/UX Design", "Parent Portal, Child Portal, 3D hallway, onboarding flow, responsive design", "$15,000 - $25,000"],
    ["Mobile App Development", "React Native app for iOS + Android with backend, user accounts, family system", "$40,000 - $65,000"],
    ["3D Hallway & Simulations", "WebGL hallway, new branching simulations, integration of existing Captivate modules", "$20,000 - $35,000"],
    ["Video & Avatar Production", "Mr. Larry intro videos, guided narrations, AI avatar for scalable content", "$10,000 - $18,000"],
    ["Testing & QA", "Alpha/beta testing, bug fixes, accessibility compliance, COPPA review", "$8,000 - $12,000"],
    ["Deployment & Launch", "App store submissions, cloud hosting setup, SCORM packaging, initial marketing", "$7,000 - $12,000"],
    ["", "", ""],
    ["TOTAL ESTIMATED RANGE", "", "$125,000 - $207,000"],
]
add_table(price_headers, price_rows, col_widths=[1.8, 2.7, 2.0])

doc.add_paragraph()

add_body(
    "Note: A phased approach allows development to begin with a smaller initial investment "
    "(Phase 1: ~$25,000-$40,000) and scale based on pilot results and funding.",
    italic=True
)

add_styled_heading("Revenue Model Considerations", 3)
add_bullet(" Family subscriptions ($9.99-$19.99/month or $99-$149/year)", bold_prefix="B2C:")
add_bullet(" School/district site licenses ($500-$2,000/year per school)", bold_prefix="B2B (Schools):")
add_bullet(" Community center and faith-based organization packages", bold_prefix="B2B (Orgs):")
add_bullet(" Corporate employee financial wellness programs", bold_prefix="Enterprise:")

doc.add_page_break()

# ============================================================
# 13. NEXT STEPS
# ============================================================

add_styled_heading("13. Next Steps", 1)

add_body("We recommend the following immediate actions to move forward:")

doc.add_paragraph()

steps = [
    ("Review & Feedback: ", "Mr. Wimsatt reviews this proposal, provides feedback on curriculum topics, platform features, and priorities."),
    ("Curriculum Deep Dive: ", "Schedule a working session to detail the content for Topics 1-4 (LIFE phase) — specific lessons, scenarios, and family activities."),
    ("Design Sprint: ", "Create high-fidelity mockups for the mobile app — Parent Portal, Child Portal, 3D hallway, and onboarding flow."),
    ("Prototype Refinement: ", "Update the existing 360 interactive prototype to reflect the finalized Topic 1 content as a live demo."),
    ("Pilot Planning: ", "Identify 5-10 pilot families for alpha testing of the Phase 1 product."),
    ("Funding Strategy: ", "Explore grant opportunities (financial literacy education grants, community development funding) and investor outreach."),
]

for i, (bold_part, rest) in enumerate(steps, 1):
    add_bullet(rest, bold_prefix=f"{i}. {bold_part}")

doc.add_paragraph()
doc.add_paragraph()

# Closing
divider = doc.add_paragraph()
divider.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = divider.add_run("_" * 60)
run.font.color.rgb = TEAL
run.font.size = Pt(10)

doc.add_paragraph()

closing = doc.add_paragraph()
closing.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = closing.add_run("Alexandria's Design LLC")
run.bold = True
run.font.size = Pt(14)
run.font.color.rgb = NAVY
run.font.name = 'Calibri'

contact = doc.add_paragraph()
contact.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = contact.add_run("Dr. Charles Martin | 310-709-4893 | alexandriasworld1234@gmail.com")
run.font.size = Pt(11)
run.font.color.rgb = MID_GRAY
run.font.name = 'Calibri'

tagline = doc.add_paragraph()
tagline.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = tagline.add_run("\"Where Families Build Financial Futures Together\"")
run.italic = True
run.font.size = Pt(12)
run.font.color.rgb = DARK_GOLD
run.font.name = 'Calibri'


# ============================================================
# SAVE
# ============================================================

doc.save(OUT)
print(f"Proposal saved to: {OUT}")
print(f"File size: {os.path.getsize(OUT) / 1024:.0f} KB")
