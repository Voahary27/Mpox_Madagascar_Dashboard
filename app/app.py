import streamlit as st
import os
import pandas as pd
from dotenv import load_dotenv
import psycopg2 
import plotly.express as px

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

def get_conf(key):
    if hasattr(st, "secrets") and key in st.secrets:
        return st.secrets[key]  
    return os.getenv(key)  # Fallback to environment variable
    

# Charger le CSS
with open("app.css") as style:
    st.markdown(f"<style>{style.read()}</style>", unsafe_allow_html=True)



st.set_page_config(page_title = "Suivie Epidemie Mpox à Madagascar", page_icon = "🦠", layout = "wide")



st.markdown(
    """<div class="header">
        <div class ="banner">
            <div class="banner-content">
                <h1>Suivi Epidémie Mpox à Madagascar</h1>
                <p>
                Analyse épidemiologique basée sur des données fictionnelles pour le suivi de la propagation du virus Mpox à Madagascar. Les données utilisées dans cette application sont générées de manière aléatoire et ne reflètent pas la réalité. Elles sont destinées à des fins éducatives et de démonstration uniquement.
                </p>
            </div>
        </div>
    </div>
        """, unsafe_allow_html = True)




# Connect to the PostgreSQL database
@st.cache_resource
def create_connection():
    conn = psycopg2.connect(
        host=get_conf("DB_HOST"),
        database=get_conf("DB_NAME"),
        user=get_conf("DB_USER"),
        password=get_conf("DB_PASSWORD"),
        port=get_conf("DB_PORT"),
        sslmode='require'
    )
    return conn


try:
    conn = create_connection()
    
except Exception as e:
    st.error(f"Erreur lors de la connexion à la base de données : {e}")

#charger les données de la BD vers un DataFrame pandas
def load_kpis(ttl=60):
    query = """
    SELECT 
        COALESCE(SUM(cas_confirmes), 0) AS total_cas,
        COALESCE(SUM(cas_suspects), 0) AS total_suspects,
        COALESCE(SUM(gueris), 0) AS total_gueris,
        COALESCE(SUM(deces), 0) AS total_deces
    FROM Epidemiologie;
    """
    return pd.read_sql(query, conn)

@st.cache_data(ttl=60)
def load_regions():
    query = """
    SELECT r.nom AS region, SUM(e.cas_confirmes) AS total_confirmes
    FROM Region r
    JOIN District d ON r.region_id = d.region_id
    JOIN Epidemiologie e ON d.district_id = e.district_id
    GROUP BY r.nom
    ORDER BY total_confirmes DESC;
    """ 
    return pd.read_sql(query, conn)

@st.cache_data(ttl=60)
def load_timeline():
    query = """
    SELECT date_rapport, SUM(cas_confirmes) AS cas_confirmes ,SUM(cas_suspects) AS cas_suspects
    FROM Epidemiologie
    GROUP BY date_rapport
    ORDER BY date_rapport;
    """
    return pd.read_sql(query, conn)

@st.cache_data(ttl=60)
def load_demographics():
    query ="""
    SELECT 
        sexe,
        CASE 
            WHEN age < 15 THEN '0-14 ans'
            WHEN age BETWEEN 15 AND 29 THEN '15-29 ans'
            WHEN age BETWEEN 30 AND 44 THEN '30-44 ans'
            ELSE '45+ ans'
        END AS tranche_age,
        COUNT(*) AS nb_patients
    FROM Patient
    GROUP BY sexe, tranche_age
    ORDER BY tranche_age;
    """
    return pd.read_sql(query, conn) 


# Affichage des KPIs
df_kpis = load_kpis()

col1, col2, col3, col4 = st.columns(4)
col1.metric("Cas Confirmés Total", int(df_kpis['total_cas'][0]))
col2.metric("Cas Suspects Total", int(df_kpis['total_suspects'][0]))
col3.metric("Guéris Total", int(df_kpis['total_gueris'][0]))
col4.metric("Décès Total", int(df_kpis['total_deces'][0]))

st.divider()

#Graphique interactif des cas confirmés par région

left_col,right_col = st.columns(2)

with left_col:
    st.subheader(" Répartition des Cas par Région")
    df_region = load_regions()
    fig_region = px.bar(
        df_region,
        x="region",
        y="total_confirmes",
        color="total_confirmes",
        labels={"region": "Région", "total_confirmes": "Cas Confirmés"},
        color_continuous_scale="Reds"
    )
    fig_region.update_layout(xaxis_tickangle=-45)
    st.plotly_chart(fig_region, use_container_width=True)

with right_col:
    st.subheader("Démographie des Patients")
    df_demo = load_demographics()
    fig_demo = px.bar(
        df_demo,
        x="tranche_age",
        y="nb_patients",
        color="sexe",
        barmode="group",
        labels={"tranche_age": "Tranche d'âge", "nb_patients": "Nombre de Patients", "sexe": "Sexe"},
        color_discrete_map={'M': '#1f77b4', 'F': '#e377c2'}
    )
    st.plotly_chart(fig_demo, use_container_width=True)

st.divider()

#Courbe d'évolution Temporelle 

st.subheader("Evolution Temporelle des Cas")
df_time = load_timeline()

fig_time = px.line(
    df_time,
    x= "date_rapport",
    y=["cas_confirmes","cas_suspects"],
    labels={"date_rapport": "Date", "value": "Nombre de cas", "variable": "Statut"},
    markers=True
  )

st.plotly_chart(fig_time, use_container_width=True)

  

