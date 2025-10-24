import React from 'react';
import { useForm, ValidationError } from '@formspree/react';

const Contact = () => {
  const [state, handleSubmit] = useForm("myzdroey");

  if (state.succeeded) {
      return <p className="success-message">Merci ! Votre message a bien été envoyé.</p>;
  }

  return (
    <section id="contact" className="contact-section">
      <div className="container">
        <h2>Entrons en contact</h2>
        <p className="section-subtitle">Nous sommes là pour répondre à toutes vos questions.</p>
        <div className="contact-container">
          <div className="contact-info">
            <h3>Informations</h3>
            <div className="info-item">
              <i className="fas fa-map-marker-alt"></i>
              <p>Senou Bamako, Mali</p>
            </div>
            <div className="info-item">
              <i className="fas fa-envelope"></i>
              <p>contact@agrilend.com</p>
            </div>
            <div className="info-item">
              <i className="fas fa-phone"></i>
              <p>+223 73 49 28 61</p>
            </div>
          </div>
          <div className="contact-form-wrapper">
            <form onSubmit={handleSubmit} className="contact-form">
              <div className="form-group">
                <label htmlFor="name">Nom complet</label>
                <input id="name" type="text" name="name" required />
              </div>
              <div className="form-group">
                <label htmlFor="email">Adresse e-mail</label>
                <input id="email" type="email" name="email" required />
                <ValidationError prefix="Email" field="email" errors={state.errors} />
              </div>
              <div className="form-group">
                <label htmlFor="message">Votre message</label>
                <textarea id="message" name="message" rows="5" required></textarea>
                <ValidationError prefix="Message" field="message" errors={state.errors} />
              </div>
              <button type="submit" className="btn btn-primary" disabled={state.submitting}>
                Envoyer le message
              </button>
            </form>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Contact;